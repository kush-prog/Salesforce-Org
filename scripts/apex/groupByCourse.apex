List<Enrollment__c> enrollmentList = [
    SELECT Id, Name, Course__c 
    FROM Enrollment__c 
    LIMIT 100
];

Map<Id, List<Enrollment__c>> groupedResult = EnrollmentUtils.groupByCourse(enrollmentList);

System.debug('Total Unique Courses Grouped: ' + groupedResult.size());

for (Id courseId : groupedResult.keySet()) {
    System.debug('Course ID: ' + courseId + ' | Enrollments Count: ' + groupedResult.get(courseId).size());
}