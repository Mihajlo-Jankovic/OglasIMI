import { HttpClient, HttpParams, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { apiProperties } from '../../_constants/api.properties';
import { HeaderUtil } from '../../_helpers/http-util';
import { Employer, Job, NewEmployer, RatingResponse } from '../_data-types/interfaces';

@Injectable({
  providedIn: 'root'
})

export class EmployerApiService {

  private url: string = apiProperties.url + '/api/employers'

  constructor(private http: HttpClient) { }

  getEmployers(notApprovedRequested: boolean): Observable<HttpResponse<Employer[]>> {
    let par: HttpParams = new HttpParams();
    par = par.set('notApprovedRequested', notApprovedRequested);
    
    return this.http.get<Employer[]>(
      this.url,
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders(),
        params: par
      }
    );
  }

  getEmployer(id: number): Observable<HttpResponse<Employer>> {
    return this.http.get<Employer>(
      this.url + `/${id}`,
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders()
      }
    );
  }

  getEmployersJobs(id: number): Observable<HttpResponse<Job[]>> {
    return this.http.get<Job[]>(
      this.url + `/${id}/jobs`,
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders()
      }
    );
  }

  createEmployer(employerData: NewEmployer): Observable<HttpResponse<null>> {
    return this.http.post<null>(
      this.url,
      employerData,
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders()
      }
    );
  }

  deleteEmployer(id: number): Observable<HttpResponse<null>> {
    return this.http.delete<null>(
      this.url + `/${id}`,
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders()
      }
    );
  }

  approveEmployer(id: number): Observable<HttpResponse<null>> {
    return this.http.put<null>(
      this.url + `/${id}`,
      {},
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders()
      }
    );
  }

  getEmployersRating(id: number): Observable<HttpResponse<RatingResponse>> {
    return this.http.get<RatingResponse>(
      this.url + `/${id}/rating`,
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders()
      }
    );
  }

  rateEmployer(id: number, rating: number): Observable<HttpResponse<null>> {
    let par: HttpParams = new HttpParams();
    par = par.set('feedbackValue', rating);

    return this.http.post<null>(
      this.url + `/${id}/rating`,
      {},
      {
        observe: 'response',
        headers: HeaderUtil.jwtOnlyHeaders(),
        params: par
      }
    );
  }

}
