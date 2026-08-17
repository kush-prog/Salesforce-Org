// Batch job that finds Enrollment__c records with no Grade that are older than 30 days, and marks them 'Incomplete'. 
// Intended to run on a weekly schedule via EnrollmentStatusBatchScheduler.

public with sharing class EnrollmentStatusBatch implements Database.Batchable<SObject> {

    private static final String INCOMPLETE_GRADE = 'Incomplete';

    public Database.QueryLocator start(Database.BatchableContext context) {
        Date cutoffDate = Date.today().addDays(-30);

        return Database.getQueryLocator([
            SELECT Id, Grade__c, Enrollment_Date__c
            FROM Enrollment__c
            WHERE Grade__c = null AND Enrollment_Date__c <= :cutoffDate
        ]);
    }

    public void execute(Database.BatchableContext context, List<Enrollment__c> scope) {
        List<Enrollment__c> enrollmentsToUpdate = new List<Enrollment__c>();

        for (Enrollment__c enrollment : scope) {
            enrollmentsToUpdate.add(new Enrollment__c(
                Id = enrollment.Id,
                Grade__c = INCOMPLETE_GRADE
            ));
        }

        if (!enrollmentsToUpdate.isEmpty()) {
            update enrollmentsToUpdate;
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug(LoggingLevel.INFO, 'EnrollmentStatusBatch completed.');
    }
}