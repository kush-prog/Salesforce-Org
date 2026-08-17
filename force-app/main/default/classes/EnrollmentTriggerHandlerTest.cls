@isTest
public class EnrollmentTriggerHandlerTest {

    @TestSetup
    static void setup() {
        Course__c course = new Course__c(
    	Name = 'Apex Fundamentals',
	    Code__c = 'APEX-101',
    	Capacity__c = 2,
    	Status__c = 'Open'
		);
		insert course;

        List<Student__c> students = new List<Student__c>{
    	new Student__c(Name = 'Alice Sharma', DOB__c = Date.today().addYears(-20), Email__c = 'alice111.test@example.com', Enrollment_Date__c = Date.today()),
    	new Student__c(Name = 'Rahul Verma', DOB__c = Date.today().addYears(-22), Email__c = 'Rahul.test@example.com', Enrollment_Date__c = Date.today())
		};
		insert students;
    }

    @isTest
    static void testCourseClosesWhenMaxSeatsReached() {
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        List<Student__c> students = [SELECT Id FROM Student__c];

        List<Enrollment__c> enrollments = new List<Enrollment__c>();
        for (Student__c student : students) {
            enrollments.add(new Enrollment__c(Course__c = course.Id, Student__c = student.Id));
        }

        Test.startTest();
        insert enrollments;
        Test.stopTest();

        Course__c updatedCourse = [SELECT Status__c FROM Course__c WHERE Id = :course.Id];
        System.assertEquals(
            'Closed',
            updatedCourse.Status__c,
            'Course should close automatically once enrollment count reaches Max Seats'
        );
    }

    @isTest
    static void testCourseReopensWhenEnrollmentDeleted() {
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        List<Student__c> students = [SELECT Id FROM Student__c];

        List<Enrollment__c> enrollments = new List<Enrollment__c>();
        for (Student__c student : students) {
            enrollments.add(new Enrollment__c(Course__c = course.Id, Student__c = student.Id));
        }
        insert enrollments;

        // Precondition check: course should already be Closed
        Course__c closedCourse = [SELECT Status__c FROM Course__c WHERE Id = :course.Id];
        System.assertEquals('Closed', closedCourse.Status__c, 'Precondition: course should be Closed before deletion');

        Test.startTest();
        delete enrollments[0];
        Test.stopTest();

        Course__c reopenedCourse = [SELECT Status__c FROM Course__c WHERE Id = :course.Id];
        System.assertEquals(
            'Open',
            reopenedCourse.Status__c,
            'Course should reopen once enrollment count drops below Max Seats'
        );
    }

    @isTest
    static void testEnrollmentStatusBatchMarksOldUngradedEnrollmentsIncomplete() {
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Student__c student = [SELECT Id FROM Student__c LIMIT 1];

        Enrollment__c oldEnrollment = new Enrollment__c(
            Course__c = course.Id,
            Student__c = student.Id,
            Enrollment_Date__c = Date.today().addDays(-40)
        );
        insert oldEnrollment;

        Test.startTest();
        Database.executeBatch(new EnrollmentStatusBatch());
        Test.stopTest();

        Enrollment__c updatedEnrollment = [SELECT Grade__c FROM Enrollment__c WHERE Id = :oldEnrollment.Id];
        System.assertEquals(
            'Incomplete',
            updatedEnrollment.Grade__c,
            'Enrollments older than 30 days with no grade should be marked Incomplete'
        );
    }

    @isTest
    static void testSchedulerKicksOffBatch() {
        Test.startTest();
        String cronExpression = '0 0 0 ? * SUN';
        System.schedule('Test Enrollment Status Scheduler', cronExpression, new EnrollmentStatusBatchScheduler());
        Test.stopTest();

        // If scheduling succeeded without exception, a CronTrigger record was created
        CronTrigger scheduledJob = [
            SELECT Id, CronExpression, State
            FROM CronTrigger
            WHERE CronExpression = :cronExpression
            LIMIT 1
        ];
        System.assertEquals('WAITING', scheduledJob.State, 'Job should be scheduled and waiting to run');
    }
}