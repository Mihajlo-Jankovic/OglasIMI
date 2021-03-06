import { Component, Input, OnInit } from '@angular/core';
import { faHome, faHouseUser } from '@fortawesome/free-solid-svg-icons';
import { UserRole } from 'src/app/_utilities/_api/_data-types/enums';
import { JWTUtil } from 'src/app/_utilities/_helpers/jwt-util';
import { AuthService } from 'src/app/_utilities/_middleware/_services/auth.service';

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.css']
})
export class NavbarComponent implements OnInit {

  @Input() public activeNav: string = '';

  public navs: Nav[] = [
    // All
    { name: 'home', allowedRoles: [] },
    { name: 'employers', allowedRoles: [] },

    { name: 'jobs-feed', allowedRoles: [UserRole.Employer, UserRole.Admin] },

    // Logged In
    { name: 'logout', allowedRoles: [UserRole.Admin, UserRole.Employer, UserRole.Applicant] },

    // Logged Out
    { name: 'login', allowedRoles: [UserRole.Visitor] },
    { name: 'register', allowedRoles: [UserRole.Visitor] },

    // Applicant
    { name: 'my-jobs-app', allowedRoles: [UserRole.Applicant] },
    { name: 'my-profile-app', allowedRoles: [UserRole.Applicant] },

    // Employer
    { name: 'new-job', allowedRoles: [UserRole.Employer] },
    { name: 'my-jobs-my-profile-app', allowedRoles: [UserRole.Employer] },

    // Admin
    { name: 'applicants', allowedRoles: [UserRole.Admin] }
  ];

  // Fontawesome
  iconHouse = faHome;
  iconHouseUser = faHouseUser;

  constructor(public acc: AuthService) { }

  ngOnInit(): void {
    // this.acc.checkAccess([]);
  }

  check(name: string): boolean {
    let index = this.navs.findIndex(n => n.name == name);
    if (index < 0) return false;

    let roles = this.navs[index].allowedRoles;
    
    return this.acc.checkRole(JWTUtil.getUserRole(), roles);
  }

  checkActive(name: string): boolean {
    return name == this.activeNav;
  }

  isAdmin() {
    return JWTUtil.getUserRole() == UserRole.Admin;
  }

  isEmployer() {
    return JWTUtil.getUserRole() == UserRole.Employer;
  }
}

interface Nav {
  name: string;
  allowedRoles: UserRole[];
}