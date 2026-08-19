// Handler class for EnrollmentTrigger. Its ONLY job is to route trigger events to EnrollmentService.
// No SOQL, no business logic — those live in EnrollmentSelector and EnrollmentService respectively.
public with sharing class EnrollmentTriggerHandler {

    public void run() {
        if (!Trigger.isAfter) {
            return;
        }

        if (Trigger.isInsert) {
            onAfterInsert((List<Enrollment__c>) Trigger.new);
        } else if (Trigger.isUpdate) {
            onAfterUpdate((List<Enrollment__c>) Trigger.new, (Map<Id, Enrollment__c>) Trigger.oldMap);
        } else if (Trigger.isDelete) {
            onAfterDelete((List<Enrollment__c>) Trigger.old);
        }
    }

    public void onAfterInsert(List<Enrollment__c> newList) {
        EnrollmentService.closeCoursesAtFullCapacity(newList);
    }

    public void onAfterUpdate(List<Enrollment__c> newList, Map<Id, Enrollment__c> oldMap) {
        // No requirement specified for this event yet.
    }

    public void onAfterDelete(List<Enrollment__c> oldList) {
        EnrollmentService.reopenCoursesBelowCapacity(oldList);
    }
}