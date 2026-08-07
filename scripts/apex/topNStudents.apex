List<AggregateResult> topStudents = EnrollmentUtils.topNStudents(5);

System.debug('Top ' + topStudents.size() + ' students by enrollment count:');
for (AggregateResult ar : topStudents) {
    Id studentId = (Id) ar.get('studentId');
    Integer count = (Integer) ar.get('enrollmentCount');
    System.debug('Student: ' + studentId + ' -> Enrollments: ' + count);
}