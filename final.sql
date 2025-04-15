-- Create the database
CREATE DATABASE Db_students;

-- Use the newly created database
USE Db_students;

-- Table: Students
CREATE TABLE tbl_students (
    studID INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    dob DATE,
    gender ENUM('Male', 'Female', 'Prefer not to say'),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    addr VARCHAR(255),
    reg_date DATE NOT NULL
);

-- Table: Courses
CREATE TABLE tbl_courses (
    course_ID INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    course_credit INT NOT NULL
);

-- Table: Enrollments
CREATE TABLE tbl_enrollments (
    enrollID INT AUTO_INCREMENT PRIMARY KEY,
    studID INT NOT NULL,
    course_ID INT NOT NULL,
    reg_date DATE NOT NULL,
    grade VARCHAR(2),
    FOREIGN KEY (studID) REFERENCES tbl_students(studID),
    FOREIGN KEY (course_ID) REFERENCES tbl_courses(course_ID),
    UNIQUE KEY (studID, course_ID)
);

-- Table: Trainers
CREATE TABLE tbl_lecturers (
    trainerID INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE
);

-- Table: CourseAssignments
CREATE TABLE tbl_courseAssignments (
    assignID INT AUTO_INCREMENT PRIMARY KEY,
    course_ID INT NOT NULL,
    trainerID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    FOREIGN KEY (course_ID) REFERENCES tbl_courses(course_ID),
    FOREIGN KEY (trainerID) REFERENCES tbl_lecturers(trainerID),
    UNIQUE KEY (course_ID, trainerID, StartDate)
);

-- Populate data for Students
INSERT INTO tbl_students (fname, lname, dob, gender, email, phone, addr, reg_date) VALUES
('James', 'Kamau', '2000-08-15', 'Male', 'kama@gmail.com', '0712345678', '123 Kisumu', '2022-10-01'),
('Peninah', 'Anne', '2002-04-20', 'Female', 'peninah@gmail.com', '0787654321', '321 Nairobi', '2023-09-01');

-- Populate data for Courses
INSERT INTO tbl_courses (course_code, course_name, course_credit) VALUES
('DICT01', 'Install Computer Software', 3),
('DICT02', 'Graphic Design', 4),
('DICT03', 'Digital Literacy', 3);

-- Sample Data for Enrollments
INSERT INTO tbl_enrollments (studID, course_ID, reg_date, grade) VALUES
(1, 1, '2024-09-05', 'B+'),
(1, 2, '2024-09-05', 'A'),
(2, 3, '2024-09-05', 'B-'),
(1, 3, '2023-09-10', 'C+');  -- Corrected the studID value for consistency

-- Populated data for trainers
INSERT INTO tbl_lecturers (fname, lname, email, phone) VALUES
('Madam. Alice', 'Makenzi', 'amakenzi@gmail.com', '0798345678'),
('Dr. Michael', 'Barasa', 'barasa@gmail.com', '0732548798');

-- Populate data for CourseAssignments
INSERT INTO tbl_courseAssignments (course_ID, trainerID, StartDate, EndDate) VALUES
(1, 1, '2023-10-12', NULL),
(2, 1, '2023-10-12', NULL),
(3, 2, '2023-10-12', NULL);





--QUESTION 2
-- Create the database
CREATE DATABASE db_student_portal;

-- Use the newly created database
USE db_student_portal;

-- Table: tbl_students
CREATE TABLE tbl_students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    dob DATE,
    gender ENUM('Male', 'Female', 'Prefer not to say') NOT NULL,
    address VARCHAR(255),
    registration_date DATE NOT NULL
);

-- Table: tbl_courses
CREATE TABLE tbl_courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_credit INT NOT NULL
);

-- Table: tbl_enrollments 
CREATE TABLE tbl_enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    grade VARCHAR(5),
    FOREIGN KEY (student_id) REFERENCES tbl_students(student_id),
    FOREIGN KEY (course_id) REFERENCES tbl_courses(course_id),
    UNIQUE KEY (student_id, course_id)
);

pip install fastapi
pip install uvicorn
pip install sqlalchemy
pip install mysql-connector-python
pip install pydantic


from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Date, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from pydantic import BaseModel
from sqlalchemy.orm import Session
import mysql.connector

# Database configuration
SQLALCHEMY_DATABASE_URL = "mysql+mysqlconnector://username:password@localhost/db_student_portal"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Models
class Student(Base):
    __tablename__ = 'tbl_students'

    student_id = Column(Integer, primary_key=True, index=True)
    fname = Column(String(50))
    lname = Column(String(50))
    email = Column(String(100), unique=True)
    phone = Column(String(20), unique=True, nullable=True)
    dob = Column(Date, nullable=True)
    gender = Column(Enum('Male', 'Female', 'Prefer not to say'))
    address = Column(String(255))
    registration_date = Column(Date)

    tbl_enrollments = relationship('Enrollment', back_populates='student')

class Course(Base):
    __tablename__ = 'tbl_courses'

    course_id = Column(Integer, primary_key=True, index=True)
    course_name = Column(String(100))
    course_code = Column(String(10), unique=True)
    course_credit = Column(Integer)

    tbl_enrollments = relationship('Enrollment', back_populates='course')

class Enrollment(Base):
    __tablename__ = 'tbl_enrollments'

    enrollment_id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey('tbl_students.student_id'))
    course_id = Column(Integer, ForeignKey('tbl_courses.course_id'))
    enrollment_date = Column(Date)
    grade = Column(String(5), nullable=True)

    student = relationship('Student', back_populates='tbl_enrollments')
    course = relationship('Course', back_populates='tbl_enrollments')

# Create the tables in the database
Base.metadata.create_all(bind=engine)

# FastAPI app setup
app = FastAPI()

# Pydantic Models for validation
class StudentCreate(BaseModel):
    fname: str
   lname: str
    email: str
    phone: str
    dob: str
    gender: str
    address: str
    registration_date: str

class StudentUpdate(BaseModel):
    fname: str
   lname: str
    email: str
    phone: str
    dob: str
    gender: str
    address: str

class CourseCreate(BaseModel):
    course_name: str
    course_code: str
    course_credit: int

class EnrollmentCreate(BaseModel):
    student_id: int
    course_id: int
    enrollment_date: str
    grade: str

# CRUD functions

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Create Student
@app.post("/tbl_students/", response_model=StudentCreate)
def create_student(student: StudentCreate, db: Session = Depends(get_db)):
    db_student = Student(**student.dict())
    db.add(db_student)
    db.commit()
    db.refresh(db_student)
    return db_student

# Get tbl_students
@app.get("/tbl_students/", response_model=list[StudentCreate])
def get_tbl_students(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Student).offset(skip).limit(limit).all()

# Update Student
@app.put("/tbl_students/{student_id}", response_model=StudentUpdate)
def update_student(student_id: int, student: StudentUpdate, db: Session = Depends(get_db)):
    db_student = db.query(Student).filter(Student.student_id == student_id).first()
    if not db_student:
        raise HTTPException(status_code=404, detail="Student not found")
    for key, value in student.dict().items():
        setattr(db_student, key, value)
    db.commit()
    db.refresh(db_student)
    return db_student

# Delete Student
@app.delete("/tbl_students/{student_id}")
def delete_student(student_id: int, db: Session = Depends(get_db)):
    db_student = db.query(Student).filter(Student.student_id == student_id).first()
    if not db_student:
        raise HTTPException(status_code=404, detail="Student not found")
    db.delete(db_student)
    db.commit()
    return {"message": "Student deleted successfully"}

# Create Course
@app.post("/tbl_courses/", response_model=CourseCreate)
def create_course(course: CourseCreate, db: Session = Depends(get_db)):
    db_course = Course(**course.dict())
    db.add(db_course)
    db.commit()
    db.refresh(db_course)
    return db_course

# Enroll Student in Course
@app.post("/tbl_enrollments/")
def enroll_student_in_course(enrollment: EnrollmentCreate, db: Session = Depends(get_db)):
    db_enrollment = Enrollment(**enrollment.dict())
    db.add(db_enrollment)
    db.commit()
    db.refresh(db_enrollment)
    return db_enrollment

# Run the FastAPI app using uvicorn
# uvicorn main:app
