List<Enrollment__c> enrollments = [
    SELECT Id, Course__c, Course__r.Name, Grade__c
    FROM Enrollment__c
    WHERE Grade__c != null
    LIMIT 50
];

Map<Id, Decimal> averages = EnrollmentUtils.averageGradePerCourse(enrollments);

// Build a quick Id -> Name lookup from the same query results
Map<Id, String> courseNames = new Map<Id, String>();
for (Enrollment__c e : enrollments) {
    if (e.Course__c != null) {
        courseNames.put(e.Course__c, e.Course__r.Name);
    }
}

for (Id courseId : averages.keySet()) {
    System.debug(courseNames.get(courseId) + ' (' + courseId + ') -> average grade points: ' + averages.get(courseId));
}