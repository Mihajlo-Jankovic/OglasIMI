use oglasimi_db;

insert into role (name)
values ('admin'),
       ('applicant'),
       ('employer');

insert into user (role_id, approved)
values (1, true),
       (2, true),
       (2, false),
       (3, true),
       (3, true);

insert into credentials (user_id, email, hashed_password)
values (1, 'misas@ad.min', '283d0cb1289e2dccb8c1ee70c5c3382d2ec25e160742ca2bcb67971dcba3d28ffa920e6bf7b37fe939e29100d96849c61f61338c5dab27943beda77137b85151'),
       (2, 'zika@bacv.anin', '5739d5d6e80ef1fbdf3b6ce697ba827108c3d1bd0f9da652803044e4861138330f315039f44d173e6f5d5cd3a8d0869c224c72c30814088b942df2eb8804a42c'),
       (3, 'pera@wuiii.com', '3a772c82dc28af481ff4099526353598f8ada4d243ddd0ae182a3ac631b7a6432afe0d215108e28a4fcd2ad61a70c8d45e97d87ba36665f8c55c18dc524105ea'),
       (4, 'laza@vass.org', 'f3c2eedfc3c558e50972dcb4d909ca391a79dd2acca9d3fc750fffe6db03a3a1431713da854fbb8bc48a2c6ffdb6f699c5cf6f6885652c6cd730ed5f9005523f'),
       (5, 'mika@yahoo.rs', 'a7fce35f48a350ae1125a3ca4e0af6e37316a9ed4555b146b9f663d52c33eda09a49aa813c9d36c1a617c2453156bb273c93eb68ece01ca7c38e5f247794104c');

insert into employer (user_id, name, tin, address, picture_base64, phone_number)
values (4, 'Lažarus d.o.o', '123456789', 'Keba Kraba, 3', null, '063123456'),
       (5, 'Perperix', '987654321', 'Lignjoslav, 8/B', null, '065987654');

insert into applicant (user_id, first_name, last_name, picture_base64, phone_number)
values (2, 'Pera', 'Peric', null, '060111222'),
       (3, 'Zika', 'Zikic', null, '062454687');

insert into admin (user_id, name)
values (1, 'MisaS.');

insert into field (name)
values ('IT'),
       ('Cvecarstvo');

insert into tag (field_id, name)
values (1, 'java'),
       (1, 'python'),
       (1, 'javascript'),
       (1, 'html'),
       (1, 'css'),
       (2, 'prodavac'),
       (2, 'vrtlarstvo'),
       (2, 'cvetni aranzmani'),
       (2, 'dekoracija');

insert into city (name)
values ('Kragujevac'),
       ('Beograd'),
       ('Nis'),
       ('Novi Sad'),
       ('Vranje'),
       ('Leskovac');

insert into job (employer_id, field_id, city_id, post_date, title, description, salary, work_from_home)
values (4, 2, 1, '2021-05-03 02:36:54.480', 'C Senior Dev', 'Opis1', '1500 - 2000 € (Mesecno)' , false),
       (4, 2, null, '2021-03-05 05:38:20.420', 'Remote Contract C++ Game Engineer', 'Opis2', '3000 € (Mesecno)', true),
       (5, 1, 1, '2021-06-08 01:15:8.360', 'Bastovan', 'Opis3', '300,000 RSD (Godisnje)', false),
       (5, 1, 3, '2021-02-01 03:20:8.360', 'Prodavac buketa', 'Opis4', '500,000 RSD (Godisnje)', false),
       (4, 2, null, '2021-02-11 08:38:20.420', 'JS Dev', 'Opis5', '800 € (Mesecno)', true),
       (4, 2, 2, '2021-03-05 12:23:18.520', 'Python Dev', 'Opis6', '1800 - 2000 € (Mesecno)', false);

insert into job_tag (job_id, tag_id)
values (1, 1),
       (1, 2),
       (2, 4),
       (3, 6),
       (3, 7),
       (2, 2);

insert into job_application (job_id, applicant_id, date)
values (1, 3, '2021-05-08 00:26:13.500'),
       (2, 3, '2021-08-02 09:12:15.220'),
       (3, 2, '2021-11-05 11:25:8.260'),
       (3, 3, '2021-07-08 07:36:2.420');