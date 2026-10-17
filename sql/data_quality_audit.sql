select *
from customer
limit 5;
-- task1: remove whitespace from email
select Customerid,
    email,
    trim(email) as trimmed_email
from customer;
-- task2: concatenate first name and last name
select customerid,
    upper(concat(lastname, ', ', firstname)) as fullname
from customer;
-- task3: concatenate first name, last name, title, and phone
select *
from employee;
select employeeid,
    concat(
        firstname,
        ' ',
        lastname,
        ', ',
        title,
        ', ',
        phone
    ) as employee_details
from employee;
-- task4: create a city code by taking the first three letters of the city name and converting them to lowercase
select *
from customer;
select customerid,
    firstname,
    lastname,
    city,
    lower(substring(city, 1, 3)) as city_code
from customer;
-- task5: create a date column by extracting the date from the invoicedate column
select *
from invoice
LIMIT 5;
select invoiceid,
    customerid,
    date(invoicedate) as date
from invoice;
-- task6: create a customer hash by concatenating the first two letters of the first name and the first two letters of the last name, all in lowercase
select *
from customer;
select customerid,
    concat(
        lower(substring(firstname, 1, 2)),
        lower(substring(lastname, 1, 2))
    ) as customer_hash
from customer;
-- task7: convert the invoiceid column to a string
select *
from invoice;
select customerid,
    total,
    cast(invoiceid as char) as invoiceid_string
from invoice;
-- Task 8: Customer Email Domain Check
select *
from customer;
select firstname,
    lastname,
    substring(email, position('@' in email) + 1) as emaildomain
from customer;
-- Task 9: Customer Name Length The marketing team is running a survey
select *
from customer;
select customerid,
    firstname,
    length(firstname) as namelength
from customer;
-- Task 10: Standardizing Employee Titles
select *
from employee;
select employeeid,
    lastname,
    lower(title) as title_lowercase
from employee;