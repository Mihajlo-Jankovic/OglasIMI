USE oglasimi_db;

-- #######################################################################
-- Procedure for checking login credentials
DELIMITER // ;
CREATE PROCEDURE check_credentials (
    IN p_email VARCHAR(320),
    IN p_hashed_password VARCHAR(128),
    OUT p_user_id INT,
    OUT p_valid_creds BOOLEAN,
    OUT p_approved BOOLEAN,
    OUT p_role VARCHAR(20)
)
BEGIN
    DECLARE v_retval INT;
    SELECT COUNT(c.user_id)
    INTO v_retval
    FROM credentials c
    WHERE c.email = p_email AND c.hashed_password = p_hashed_password;

    IF v_retval != 0 THEN
        SET p_valid_creds = TRUE;
    ELSE
        SET p_valid_creds = FALSE;
    END IF;

    SELECT u.id, u.approved, r.name
    INTO p_user_id, p_approved, p_role
    FROM credentials c
         JOIN user u ON c.user_id = u.id
         JOIN role r ON u.role_id = r.id
    WHERE c.email = p_email
    LIMIT 1;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for all fields selection

DELIMITER // ;
CREATE PROCEDURE get_all_fields ()
BEGIN
    SELECT *
    FROM field;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for all cities selection

DELIMITER // ;
CREATE PROCEDURE get_all_cities ()
BEGIN
    SELECT *
    FROM city;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for tag list

DELIMITER // ;
CREATE PROCEDURE get_tag_list (IN id INT)
BEGIN
    SELECT *
    FROM tag
    WHERE field_id = id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for employer registration
DELIMITER // ;
CREATE PROCEDURE register_employer (
    IN p_email VARCHAR(320),
    IN p_hashed_password VARCHAR(128),
    IN p_picture_base64 TEXT(65000),
    IN p_phone_number VARCHAR(30),
    IN p_name VARCHAR(50),
    IN p_address VARCHAR(80),
    IN p_tin VARCHAR(9),
    OUT p_is_added BOOLEAN,
    OUT p_already_exists BOOLEAN
)
leave_label:BEGIN

    DECLARE v_retval INT;
    DECLARE v_employer_role_id INT;
    DECLARE v_employer_id INT;

    DECLARE exit HANDLER FOR sqlexception
        BEGIN
            ROLLBACK;
        END;
    DECLARE exit HANDLER FOR sqlwarning
        BEGIN
            ROLLBACK;
        END;


    SET p_is_added = FALSE;
    SET p_already_exists = FALSE;

    -- count number of users which have the same email as user that is attempting to make
    -- an account
    SELECT COUNT(c.user_id)
    INTO v_retval
    FROM credentials c
    WHERE c.email = p_email;

    -- if provided email already exists inside database exit procedure
    IF v_retval != 0 THEN
        SET p_already_exists = TRUE;
        LEAVE leave_label;
    END IF;

    -- get id for role employer
    SELECT id
    INTO v_employer_role_id
    FROM role
    WHERE name = 'employer';

    START TRANSACTION;

    -- add employer into table "user"
    INSERT INTO user ( role_id, approved )
        VALUES ( v_employer_role_id, FALSE );

    IF ROW_COUNT() = 0
    THEN
        ROLLBACK;
    END IF;

    -- get employer's id
    SELECT LAST_INSERT_ID()
    INTO v_employer_id;

    -- add employer's profile details into table "employer"
    INSERT INTO employer ( user_id, picture_base64, phone_number, name, address, tin )
        VALUES ( v_employer_id, p_picture_base64, p_phone_number, p_name, p_address, p_tin );

    IF ROW_COUNT() = 0
    THEN
        ROLLBACK;
    END IF;

    -- add employer's credentials into table "credentials"
    INSERT INTO credentials ( user_id, email, hashed_password  )
    VALUES ( v_employer_id, p_email, p_hashed_password );

    IF ROW_COUNT() = 0
    THEN
        ROLLBACK;
    END IF;

    SET p_is_added = TRUE;

    COMMIT;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for applicant registration
DELIMITER // ;
CREATE PROCEDURE register_applicant (
    IN p_email VARCHAR(320),
    IN p_hashed_password VARCHAR(128),
    IN p_first_name VARCHAR(30),
    IN p_last_name VARCHAR(30),
    IN p_picture_base64 TEXT(65000),
    IN p_phone_number VARCHAR(30),
    OUT p_is_added BOOLEAN,
    OUT p_already_exists BOOLEAN
)
leave_label:BEGIN

    DECLARE v_retval INT;
    DECLARE v_applicant_role_id INT;
    DECLARE v_applicant_id INT;

    DECLARE exit HANDLER FOR sqlexception
        BEGIN
            ROLLBACK;
        END;
    DECLARE exit HANDLER FOR sqlwarning
        BEGIN
            ROLLBACK;
        END;


    SET p_is_added = FALSE;
    SET p_already_exists = FALSE;

    -- count number of users which have the same email as user that is attempting to make
    -- an account
    SELECT COUNT(c.user_id)
    INTO v_retval
    FROM credentials c
    WHERE c.email = p_email;

    -- if provided email already exists inside database exit procedure
    IF v_retval != 0 THEN
        SET p_already_exists = TRUE;
        LEAVE leave_label;
    END IF;

    -- get id for role applicant
    SELECT id
    INTO v_applicant_role_id
    FROM role
    WHERE name = 'applicant';

    START TRANSACTION;

    -- add applicant into table "user"
    INSERT INTO user ( role_id, approved )
    VALUES ( v_applicant_role_id, FALSE );

    IF ROW_COUNT() = 0
    THEN
        ROLLBACK;
    END IF;

    -- get applicant's id
    SELECT LAST_INSERT_ID()
    INTO v_applicant_id;

    -- add applicant's profile details into table "applicant"
    INSERT INTO applicant (user_id, first_name, last_name, picture_base64, phone_number)
    VALUES ( v_applicant_id, p_first_name, p_last_name, p_picture_base64, p_phone_number );

    IF ROW_COUNT() = 0
    THEN
        ROLLBACK;
    END IF;

    -- add applicant's credentials into table "credentials"
    INSERT INTO credentials ( user_id, email, hashed_password  )
    VALUES ( v_applicant_id, p_email, p_hashed_password );

    IF ROW_COUNT() = 0
    THEN
        ROLLBACK;
    END IF;

    SET p_is_added = TRUE;

    COMMIT;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting list of all employers
DELIMITER // ;
CREATE PROCEDURE get_all_employers(
    IN p_not_approved_requested BOOLEAN
)
BEGIN
    SELECT e.user_id, e.name, e.tin, e.address, e.picture_base64, e.phone_number, c.email, approved
    FROM employer e
        JOIN credentials c ON e.user_id = c.user_id
        JOIN user u ON e.user_id = u.id
    WHERE u.approved <> p_not_approved_requested;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting an employer
DELIMITER // ;
CREATE PROCEDURE get_employer(
    IN p_id INT
)
BEGIN
    SELECT e.user_id, e.name, e.tin, e.address, e.picture_base64, e.phone_number, c.email
    FROM employer e
        JOIN credentials c ON e.user_id = c.user_id
        JOIN user u on e.user_id = u.id
    WHERE e.user_id = p_id
        AND u.approved = TRUE;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting an user
DELIMITER // ;
CREATE PROCEDURE get_user(
    IN p_id INT
)
BEGIN
    SELECT c.user_id, c.email, c.hashed_password
    FROM credentials c
        JOIN user u on c.user_id = u.id
    WHERE c.user_id = p_id
      AND u.approved = TRUE;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for approving user registration
DELIMITER // ;
CREATE PROCEDURE approve_user(
    IN p_id INT,
    OUT p_approved_successfully BOOLEAN
)
BEGIN
    SET p_approved_successfully = FALSE;

    UPDATE user
    SET approved = TRUE
    WHERE id = p_id AND approved = FALSE;

    IF ROW_COUNT() != 0
    THEN
        SET p_approved_successfully = TRUE;
    END IF;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for deleting user's records from the database
DELIMITER // ;
CREATE PROCEDURE delete_user(
    IN p_id INT,
    OUT p_deleted_successfully BOOLEAN
)
BEGIN
    SET p_deleted_successfully = FALSE;

    DELETE u.*
    FROM user u
    INNER JOIN role r ON u.role_id = r.id
    WHERE u.id = p_id AND r.name <> 'admin';

    IF ROW_COUNT() != 0
    THEN
        SET p_deleted_successfully = TRUE;
    END IF;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for applicants which applied for particular job
DELIMITER // ;
CREATE PROCEDURE get_job_applicants(
    IN p_job_id INT
)
BEGIN
    SELECT a.*, c.email, c.hashed_password
    FROM applicant a
        JOIN job_application ja on a.user_id = ja.applicant_id
        JOIN credentials c on a.user_id = c.user_id
    WHERE p_job_id = job_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for applying to particular job
DELIMITER // ;
CREATE PROCEDURE apply_for_a_job(
    IN p_job_id INT,
    IN p_applicant_id INT,
    OUT p_successfully_applied INT
)
BEGIN
    SET p_successfully_applied = FALSE;

    INSERT INTO job_application (job_id, applicant_id, date)
    VALUES (p_job_id, p_applicant_id, NOW() );

    IF ROW_COUNT() != 0
    THEN
        SET p_successfully_applied = TRUE;
    END IF;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting employer's job posts (without tags)
DELIMITER // ;
CREATE PROCEDURE employer_get_posts_without_tags(
    IN p_employer_id INT
)
BEGIN
    SELECT j.*,
           c.name AS 'city_name',
           f.name AS 'field_name',
           e.name AS 'employer_name', e.phone_number, e.picture_base64, e.address, e.tin,
           creds.email
    FROM job j
        JOIN employer e on e.user_id = j.employer_id
        LEFT JOIN city c on c.id = j.city_id
        JOIN field f on f.id = j.field_id
        JOIN credentials creds on j.employer_id = creds.user_id
    WHERE p_employer_id = j.employer_id;
END //
DELIMITER ;

-- DROP PROCEDURE employer_get_posts_without_tags
-- #######################################################################



-- #######################################################################
-- Procedure for getting tags for particular job
DELIMITER // ;
CREATE PROCEDURE get_tags_for_a_job(
    IN p_job_id INT
)
BEGIN
    SELECT t.*
    FROM job_tag jt
        JOIN tag t on jt.tag_id = t.id
    WHERE p_job_id = jt.job_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Main procedure for getting filtered jobs
DELIMITER // ;
CREATE PROCEDURE get_filtered_jobs
(
    IN p_employer_id INT,
    IN p_field_id INT,
    IN p_city_id INT,
    IN p_title VARCHAR(50),
    IN p_work_from_home BOOLEAN
)
BEGIN
    SELECT j.*,
           f.id f_id, f.name f_name,
           c.id c_id, c.name c_name,
           e.user_id, e.name e_name, e.tin, e.address, e.picture_base64,e.phone_number
    FROM job j LEFT JOIN field f ON j.field_id = f.id
               LEFT JOIN city c ON c.id = j.city_id
               LEFT JOIN employer e ON e.user_id = j.employer_id
    WHERE
        (p_field_id = 0 OR p_field_id = field_id)
      AND (p_employer_id = 0 OR p_employer_id = employer_id)
      AND (p_city_id = 0 OR p_city_id = city_id)
      AND (p_title IS NULL OR p_title = 'default' OR title RLIKE(CONCAT(p_title,'+')))
      AND (p_work_from_home = FALSE OR p_work_from_home = work_from_home)
    ORDER BY post_date DESC;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure job counting
DELIMITER // ;
CREATE PROCEDURE count_jobs()
BEGIN
    SELECT COUNT(*) AS job_num
    FROM job;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for job posting
DELIMITER // ;
CREATE PROCEDURE post_job (
    IN p_employer_id INT,
    IN p_field_id INT,
    IN p_city_id INT,
    IN p_title VARCHAR(50),
    IN p_description TEXT(10000),
    IN p_salary VARCHAR(50),
    IN p_work_from_home BOOLEAN,
    OUT p_is_posted BOOLEAN
)
BEGIN
    INSERT INTO job (employer_id, field_id, city_id, post_date, title, description, salary, work_from_home)
    VALUES (p_employer_id, p_field_id,
            IF(p_city_id = 0, null, p_city_id), NOW(), p_title, p_description, p_salary, p_work_from_home);
    SELECT id FROM job WHERE id = LAST_INSERT_ID();

    IF ROW_COUNT() != 0
    THEN
        SET p_is_posted = TRUE;
    END IF;

END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for tag inserting
DELIMITER // ;
CREATE PROCEDURE insert_tag (
    IN p_job_id INT,
    IN p_tag_id INT,
    OUT p_is_inserted BOOLEAN
)
BEGIN
    INSERT INTO job_tag (job_id, tag_id)
    VALUES (p_job_id, p_tag_id);
    SELECT id FROM job WHERE id = LAST_INSERT_ID();

    IF ROW_COUNT() != 0
    THEN
        SET p_is_inserted = TRUE;
    END IF;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting specific job by id
DELIMITER // ;
CREATE PROCEDURE get_job(IN p_id INT)
BEGIN
    SELECT t2.*, t1.email FROM credentials t1 JOIN (SELECT j.*,
           f.id f_id, f.name f_name,
           c.id c_id, c.name c_name,
           e.user_id, e.name e_name, e.tin, e.address, e.picture_base64,e.phone_number
    FROM job j
        LEFT JOIN field f ON j.field_id = f.id
        LEFT JOIN city c ON c.id = j.city_id
        LEFT JOIN employer e ON e.user_id = j.employer_id
    WHERE p_id = j.id) t2 ON t1.user_id = t2.user_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for job deleting
DELIMITER // ;
CREATE PROCEDURE delete_job (
    IN p_id int,
    OUT p_is_deleted boolean
)
BEGIN
    DELETE FROM job WHERE p_id = id;

    IF ROW_COUNT() != 0
    THEN
        SET p_is_deleted = TRUE;
    END IF;

END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting applicants
DELIMITER // ;
CREATE PROCEDURE get_applicant (IN p_id INT)
BEGIN
    SELECT a.*, c.email
    FROM applicant a
        JOIN credentials c ON a.user_id = c.user_id
    WHERE p_id = a.user_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for checking if user is approved
DELIMITER // ;
CREATE PROCEDURE check_if_approved (IN p_id INT)
BEGIN
    SELECT approved FROM user
    WHERE p_id = id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for checking if applicant applied on some of specific employer jobs
DELIMITER // ;
CREATE PROCEDURE check_application (
    IN p_employer_id INT,
    IN p_applicant_id INT
)
BEGIN
    SELECT COUNT(*) AS count
    FROM job j
        JOIN job_application ja ON j.id = ja.job_id
    WHERE employer_id = p_employer_id AND applicant_id = p_applicant_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for selecting all applicants approved or not approved
DELIMITER // ;
CREATE PROCEDURE get_all_applicants (IN p_approved BOOLEAN)
BEGIN
    SELECT a.*, c.email, u.approved
    FROM applicant a
        JOIN user u ON u.id = a.user_id
        JOIN credentials c ON a.user_id = c.user_id
    WHERE u.approved = p_approved;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting all jobs that applicant applied on
DELIMITER // ;
CREATE PROCEDURE get_jobs_applicant_applied_on (IN p_id INT)
BEGIN
    SELECT t2.*, t1.email
    FROM credentials t1
        JOIN (
            SELECT j.*,
            f.id f_id, f.name f_name,
            c.id c_id, c.name c_name,
            e.user_id, e.name e_name, e.tin, e.address, e.picture_base64,e.phone_number
            FROM job_application a JOIN job j ON a.job_id = j.id
                           LEFT JOIN field f ON j.field_id = f.id
                           LEFT JOIN city c ON c.id = j.city_id
                           LEFT JOIN employer e ON e.user_id = j.employer_id
            WHERE applicant_id = p_id
            ) t2 ON t1.user_id = t2.user_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting feedback values
DELIMITER // ;
CREATE PROCEDURE get_feedback_values (IN p_id INT)
BEGIN
    SELECT * FROM rating
    WHERE p_id = employer_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for employer rating
DELIMITER // ;
CREATE PROCEDURE rate_employer (
    IN p_employer_id INT,
    IN p_applicant_id INT,
    IN p_feedback_value TINYINT,
    OUT p_is_rated BOOLEAN
)
BEGIN
    INSERT INTO rating (employer_id,applicant_id,feedback_value)
    VALUES (p_employer_id,p_applicant_id,p_feedback_value);

    IF ROW_COUNT() != 0
    THEN
        SET p_is_rated = TRUE;
    END IF;

END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for checking if appliacant already rated employer
DELIMITER // ;
CREATE PROCEDURE check_if_rated (
    IN p_employer_id INT,
    IN p_applicant_id INT
)
BEGIN
    SELECT COUNT(*) AS count
    FROM rating
    WHERE p_employer_id = employer_id AND p_applicant_id = applicant_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for getting all comments on a specific job
DELIMITER // ;
CREATE PROCEDURE get_all_comments (
    IN p_job_id INT
)
BEGIN
    SELECT c.*, a.first_name AS f_name, a.last_name AS l_name, e.name AS name
    FROM comment c
        LEFT JOIN applicant a ON c.author_id = a.user_id
        LEFT JOIN employer e ON c.author_id = e.user_id
    WHERE p_job_id = job_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for comment posting
DELIMITER // ;
CREATE PROCEDURE post_comment (
    IN p_author_id INT,
    IN p_job_id INT,
    IN p_parent_id INT,
    IN p_text VARCHAR(1000),
    OUT p_is_posted BOOLEAN
)
BEGIN
    INSERT INTO comment (author_id, job_id, parent_id, text, post_date)
    VALUES (p_author_id, p_job_id, IF(p_parent_id = 0, null, p_parent_id), p_text, NOW());

    IF ROW_COUNT() != 0
    THEN
        SET p_is_posted = TRUE;
    END IF;

END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for checking if it is employers job
DELIMITER // ;
CREATE PROCEDURE chec_if_employers_job (
    IN p_job_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT COUNT(*) AS count
    FROM job
    WHERE p_job_id = id AND p_user_id = employer_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for comments deleting
DELIMITER // ;
CREATE PROCEDURE delete_comment (
    IN p_id INT,
    OUT p_is_deleted BOOLEAN
)
BEGIN
    DELETE FROM comment WHERE p_id = id OR p_id = parent_id;

    IF ROW_COUNT() != 0
    THEN
        SET p_is_deleted = TRUE;
    END IF;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for counting total number of likes on a specific job
DELIMITER // ;
CREATE PROCEDURE count_likes (
    IN p_job_id INT
)
BEGIN
    SELECT COUNT(*) AS count
    FROM t_like
    WHERE p_job_id = job_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for checking if applicant alrady liked a job
DELIMITER // ;
CREATE PROCEDURE check_if_already_liked (
    IN p_job_id INT,
    IN p_applicant_id INT
)
BEGIN
    SELECT COUNT(*) AS count
    FROM t_like
    WHERE p_job_id = job_id AND p_applicant_id = applicant_id;
END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for job like
DELIMITER // ;
CREATE PROCEDURE like_job (
    IN p_job_id INT,
    IN p_applicant_id INT,
    OUT p_is_liked BOOLEAN
)
BEGIN
    INSERT INTO t_like(applicant_id,job_id)
    VALUES (p_applicant_id,p_job_id);

    IF ROW_COUNT() != 0
    THEN
        SET p_is_liked = TRUE;
    END IF;

END //
DELIMITER ;
-- #######################################################################



-- #######################################################################
-- Procedure for like recall
DELIMITER // ;
CREATE PROCEDURE recall_like (
    IN p_job_id INT,
    IN p_applicant_id INT,
    OUT p_is_deleted BOOLEAN
)
BEGIN
    DELETE FROM t_like
    WHERE p_job_id = job_id AND p_applicant_id = applicant_id;

    IF ROW_COUNT() != 0
    THEN
        SET p_is_deleted = TRUE;
    END IF;
END //
DELIMITER ;