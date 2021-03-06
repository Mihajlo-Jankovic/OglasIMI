package com.tim1.oglasimi.repository.implementation;

import com.tim1.oglasimi.model.*;
import com.tim1.oglasimi.model.payload.RatingResponse;
import com.tim1.oglasimi.repository.EmployerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.LinkedList;
import java.util.List;

@Repository
public class EmployerRepositoryImpl implements EmployerRepository {

    private static final Logger LOGGER = LoggerFactory.getLogger(EmployerRepositoryImpl.class);

    private static final String REGISTER_EMPLOYER_PROCEDURE_CALL = "{call register_employer(?,?,?,?,?,?,?,?,?)}";
    private static final String GET_ALL_EMPLOYERS_PROCEDURE_CALL = "{call get_all_employers(?)}";
    private static final String GET_EMPLOYER_PROCEDURE_CALL = "{call get_employer(?)}";
    private static final String APPROVE_EMPLOYER_PROCEDURE_CALL = "{call approve_user(?,?)}";
    private static final String DELETE_EMPLOYER_PROCEDURE_CALL = "{call delete_user(?,?)}";
    private static final String GET_FEEDBACK_VALUES_STORED_PROCEDURE = "{call get_feedback_values(?)}";
    private static final String APPLICATION_STORED_PROCEDURE = "{call check_application(?,?)}";
    private static final String RATE_EMPLOYER_STORED_PROCEDURE = "{call rate_employer(?,?,?,?)}";
    private static final String IS_RATED_STORED_PROCEDURE = "{call check_if_rated(?,?)}";

    /** returns data for jobs without tag names for those jobs
     * GET_TAGS_A_JOB_PROCEDURE_CALL is used to get remaining job data */
    private static final String EMPLOYER_GET_POSTS_PROCEDURE_CALL = "{call employer_get_posts_without_tags(?)}";
    private static final String GET_TAGS_A_JOB_PROCEDURE_CALL = "{call get_tags_for_a_job(?)}";

    @Value("${spring.datasource.url}")
    private String databaseSourceUrl;

    @Value("${spring.datasource.username}")
    private String databaseUsername;

    @Value("${spring.datasource.password}")
    private String databasePassword;

    /**
     * Returns list of all employers, approved and not approved "
     * */
    @Override
    public List<Employer> getAll() {
        return getAll(false);
    }

    public List<Employer> getAll(boolean notApprovedRequested) {
        List<Employer> employers = new LinkedList<>();

        try ( Connection con = DriverManager.getConnection( databaseSourceUrl, databaseUsername, databasePassword );
              CallableStatement cstmt = con.prepareCall(GET_ALL_EMPLOYERS_PROCEDURE_CALL) ) {

            cstmt.setBoolean("p_not_approved_requested", notApprovedRequested );

            ResultSet resultSet = cstmt.executeQuery();

            Employer tempEmployer;

            while( resultSet.next() ) {
                tempEmployer = new Employer();
                tempEmployer.setId( resultSet.getInt("user_id") );
                tempEmployer.setEmail( resultSet.getString("email") );
                tempEmployer.setPictureBase64( resultSet.getString("picture_base64") );
                tempEmployer.setPhoneNumber( resultSet.getString("phone_number") );
                tempEmployer.setName( resultSet.getString("name") );
                tempEmployer.setAddress( resultSet.getString("address") );
                tempEmployer.setTin( resultSet.getString("tin") );

                employers.add(tempEmployer);
            }

        }
        catch ( SQLException e ) {
            LOGGER.error("getAll | An error occurred while communicating with a database", e );
            e.printStackTrace();
        }

        return employers;
    }

    @Override
    public boolean create(Employer employer) {
        boolean isSuccessfullyRegistered = false;

        try ( Connection con = DriverManager.getConnection( databaseSourceUrl, databaseUsername, databasePassword );
                CallableStatement cstmt = con.prepareCall(REGISTER_EMPLOYER_PROCEDURE_CALL) ) {

            cstmt.setString("p_email", employer.getEmail() );
            cstmt.setString("p_hashed_password", employer.getHashedPassword() );
            cstmt.setString("p_picture_base64", employer.getPictureBase64() );
            cstmt.setString("p_phone_number", employer.getPhoneNumber() );
            cstmt.setString("p_name", employer.getName() );
            cstmt.setString("p_address", employer.getAddress() );
            cstmt.setString("p_tin", employer.getTin() );

            cstmt.registerOutParameter("p_is_added", Types.BOOLEAN);
            cstmt.registerOutParameter("p_already_exists", Types.BOOLEAN);
            cstmt.execute();

            isSuccessfullyRegistered = cstmt.getBoolean("p_is_added");
            boolean alreadyExists = cstmt.getBoolean("p_already_exists");
            if( ! isSuccessfullyRegistered && ! alreadyExists )
                throw new Exception("transaction failed");

        }
        catch ( Exception e ) {
            LOGGER.error("create | An error occurred while communicating with a database.");
            LOGGER.error("create | {}", e.getMessage() );
            e.printStackTrace();
        }

        return isSuccessfullyRegistered;
    }

    @Override
    public Employer get(Integer id) {
        Employer employer = null;

        try ( Connection con = DriverManager.getConnection( databaseSourceUrl, databaseUsername, databasePassword );
                CallableStatement cstmt = con.prepareCall(GET_EMPLOYER_PROCEDURE_CALL) ) {

            cstmt.setInt("p_id", id);
            ResultSet resultSet = cstmt.executeQuery();

            if( resultSet.first() ) {
                employer = new Employer(
                        resultSet.getInt("user_id"),
                        resultSet.getString("email"),
                        null,
                        resultSet.getString("picture_base64"),
                        resultSet.getString("phone_number"),
                        resultSet.getString("name"),
                        resultSet.getString("address"),
                        resultSet.getString("tin")
                );
            }

        } catch ( SQLException e ) {
            LOGGER.error("get | An error occurred while communicating with a database", e );
            e.printStackTrace();
        }

        return employer;
    }

    @Override
    public boolean update(Employer employer, Integer integer) {
        return false;
    }

    @Override
    public boolean delete(Integer id) {
        boolean isDeletedSuccessfully = false;

        try ( Connection con = DriverManager.getConnection( databaseSourceUrl, databaseUsername, databasePassword );
            CallableStatement cstmt = con.prepareCall(DELETE_EMPLOYER_PROCEDURE_CALL ) ) {

            cstmt.setInt("p_id", id);
            cstmt.registerOutParameter("p_deleted_successfully", Types.BOOLEAN);

            cstmt.executeUpdate();

            isDeletedSuccessfully = cstmt.getBoolean("p_deleted_successfully");

        } catch ( SQLException e ) {
            LOGGER.error("delete | An error occurred while communicating with a database", e );
            e.printStackTrace();
        }

        return isDeletedSuccessfully;
    }

    @Override
    public boolean approve(Integer id) {
        boolean isApprovedSuccessfully = false;

        try ( Connection con = DriverManager.getConnection( databaseSourceUrl, databaseUsername, databasePassword );
                CallableStatement cstmt = con.prepareCall(APPROVE_EMPLOYER_PROCEDURE_CALL) ) {

            cstmt.setInt("p_id", id);
            cstmt.registerOutParameter("p_approved_successfully", Types.BOOLEAN);

            cstmt.executeUpdate();

            isApprovedSuccessfully = cstmt.getBoolean("p_approved_successfully");

        } catch ( SQLException e ) {
            LOGGER.error("approve | An error occurred while communicating with a database", e );
            e.printStackTrace();
        }

        return isApprovedSuccessfully;
    }

    @Override
    public List<Job> getPostedJobs(int id) {
        List<Job> postedJobs = null;

        try ( Connection con = DriverManager.getConnection( databaseSourceUrl, databaseUsername, databasePassword );
              CallableStatement cstmt = con.prepareCall(EMPLOYER_GET_POSTS_PROCEDURE_CALL);
              CallableStatement csTags = con.prepareCall(GET_TAGS_A_JOB_PROCEDURE_CALL)) {

            cstmt.setInt("p_employer_id", id);
            ResultSet rs = cstmt.executeQuery();

            int jobId;
            Job tempJob;
            Tag tempTag;
            List<Tag> tags;
            postedJobs = new LinkedList<>();

            while( rs.next() ) {
                tempJob = new Job();

                tempJob.setId( rs.getInt("id") );

                tempJob.setField( new Field(
                       rs.getInt("field_id"),
                       rs.getString("field_name")
                ));

                tempJob.setEmployer( new Employer(
                        rs.getInt("employer_id"),
                            null,
                            null,
                        rs.getString("picture_base64"),
                        rs.getString("phone_number"),
                        rs.getString("employer_name"),
                        rs.getString("address"),
                        rs.getString("tin")
                ));

                tempJob.setCity( new City(
                        rs.getInt("city_id"),
                        rs.getString("city_name")
                ));

                tempJob.setPostDate( rs.getObject("post_date", LocalDateTime.class) );
                tempJob.setDescription( rs.getString("description") );
                tempJob.setTitle( rs.getString("title") );
                tempJob.setSalary( rs.getString("salary") );
                tempJob.setWorkFromHome( rs.getBoolean("work_from_home") );

                csTags.setInt("p_job_id", tempJob.getId() );
                ResultSet rsTags = csTags.executeQuery();

                tags = new LinkedList<>();

                while( rsTags.next() ) {
                    tempTag = new Tag(
                            rsTags.getInt("id"),
                            rsTags.getInt("field_id"),
                            rsTags.getString("name")
                    );

                    tags.add( tempTag );
                }
                tempJob.setTags( tags );

                postedJobs.add(tempJob);
            }
        }
        catch ( SQLException e ) {
            LOGGER.error("getPostedJobs | An error occurred while communicating with a database" );
            e.printStackTrace();
        }

        return postedJobs;
    }

    @Override
    public RatingResponse getRating(int employerId, int applicantId, boolean isApplicant)
    {
        RatingResponse ratingResponse = null;

        try ( Connection con = DriverManager.getConnection( databaseSourceUrl, databaseUsername, databasePassword );
              CallableStatement cstmt = con.prepareCall(GET_FEEDBACK_VALUES_STORED_PROCEDURE);
              CallableStatement cstmtRated = con.prepareCall(IS_RATED_STORED_PROCEDURE))
        {
            cstmt.setInt("p_id",employerId);
            ResultSet rs = cstmt.executeQuery();

            if(rs.first())
            {
                ratingResponse = new RatingResponse();
                ratingResponse.setRating(-1);

                double tmpSum = 0;
                int counter = 0;

                rs.beforeFirst();
                while(rs.next())
                {
                    counter++;
                    tmpSum += rs.getByte("feedback_value");
                }

                ratingResponse.setRating(tmpSum/counter);
                ratingResponse.setAlreadyRated(false);

                if(isApplicant)
                {
                    cstmtRated.setInt("p_employer_id",employerId);
                    cstmtRated.setInt("p_applicant_id",applicantId);

                    rs = cstmtRated.executeQuery();
                    rs.first();

                    int count = rs.getInt("count");

                    if(count != 0) ratingResponse.setAlreadyRated(true);
                }
            }
        }

        catch (SQLException throwables) {
            throwables.printStackTrace();
        }

        return ratingResponse;
    }

    @Override
    public boolean rate(int employerId, int applicantId, byte feedbackValue)
    {
        boolean isSuccessfullyRated = false;

        if(!isApplied(employerId,applicantId)) return false;

        try (Connection con = DriverManager.getConnection(databaseSourceUrl,databaseUsername,databasePassword );
             CallableStatement cstmt = con.prepareCall(RATE_EMPLOYER_STORED_PROCEDURE))
        {

            cstmt.setInt("p_applicant_id",applicantId);
            cstmt.setInt("p_employer_id",employerId);
            cstmt.setByte("p_feedback_value",feedbackValue);
            cstmt.registerOutParameter("p_is_rated", Types.BOOLEAN);

            cstmt.executeUpdate();

            isSuccessfullyRated = cstmt.getBoolean("p_is_rated");
        }

        catch ( SQLException e ) {
            LOGGER.error("approve | An error occurred while communicating with a database", e );
            e.printStackTrace();
        }

        return isSuccessfullyRated;
    }

    // Da li je aplikant prijavljen na neki od poslodavcevih poslova
    public boolean isApplied(int employerId, int applicantId)
    {
        boolean flag = false;

        try (Connection con = DriverManager.getConnection(databaseSourceUrl, databaseUsername, databasePassword);
             CallableStatement cstmt = con.prepareCall(APPLICATION_STORED_PROCEDURE))
        {
            cstmt.setInt("p_employer_id",employerId);
            cstmt.setInt("p_applicant_id",applicantId);

            ResultSet rs = cstmt.executeQuery();

            rs.first();
            if(rs.getInt("count") != 0) flag = true;
        }

        catch (SQLException throwables) {
            throwables.printStackTrace();
        }

        return flag;
    }
}
