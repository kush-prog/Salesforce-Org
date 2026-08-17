public with sharing class EnrollmentStatusBatchScheduler implements Schedulable {

    public void execute(SchedulableContext context) {
        Database.executeBatch(new EnrollmentStatusBatch());
    }
}