public with sharing class EnrollmentUtils {

    public static Map<Id, List<Enrollment__c>> groupByCourse(List<Enrollment__c> enrollments) {
        Map<Id, List<Enrollment__c>> courseToEnrollments = new Map<Id, List<Enrollment__c>>();

        if (enrollments == null || enrollments.isEmpty()) {
            return courseToEnrollments;
        }

        for (Enrollment__c enr : enrollments) {
            Id courseId = enr.Course__c;
            if (courseId == null) {
                continue;
            }
            if (!courseToEnrollments.containsKey(courseId)) {
                courseToEnrollments.put(courseId, new List<Enrollment__c>());
            }
            courseToEnrollments.get(courseId).add(enr);
        }

        return courseToEnrollments;
    }

	public static Map<Id, Decimal> averageGradePerCourse(List<Enrollment__c> enrollments) {
    	Map<Id, Decimal> courseToAverage = new Map<Id, Decimal>();

    	if (enrollments == null || enrollments.isEmpty()) {
        	return courseToAverage;
    	}

    	// Accumulate running totals and counts per course
    	Map<Id, Decimal> courseToTotal = new Map<Id, Decimal>();
    	Map<Id, Integer> courseToCount = new Map<Id, Integer>();

    	for (Enrollment__c enr : enrollments) {
        	Id courseId = enr.Course__c;

        	if (courseId == null) {
            	continue;
        	}
        	if (enr.Grade__c == null || !GRADE_POINTS.containsKey(enr.Grade__c)) {
            	continue;
        	}

        	Decimal points = GRADE_POINTS.get(enr.Grade__c);

	        if (!courseToTotal.containsKey(courseId)) {
    	        courseToTotal.put(courseId, 0);
        	    courseToCount.put(courseId, 0);
        	}

	        courseToTotal.put(courseId, courseToTotal.get(courseId) + points);
    	    courseToCount.put(courseId, courseToCount.get(courseId) + 1);
    	}

    	// Compute averages from the totals
	    for (Id courseId : courseToTotal.keySet()) {
    	    Decimal total = courseToTotal.get(courseId);
        	Integer count = courseToCount.get(courseId);
	        courseToAverage.put(courseId, total.divide(count, 2));
    	}

	    return courseToAverage;
	}
    private static Map<String, Decimal> GRADE_POINTS = new Map<String, Decimal>{
    	'A' => 5.0,
   	 	'B' => 4.0,
    	'C' => 3.0,
    	'D' => 2.0,
    	'E' => 1.0,
        'F' => 0.0
	};

    public static List<AggregateResult> topNStudents(Integer n) {
        if (n == null || n <= 0) {
            return new List<AggregateResult>();
        }

        List<AggregateResult> results = [
            SELECT Student__c studentId, COUNT(Id) enrollmentCount
            FROM Enrollment__c
            WHERE Student__c != null
            GROUP BY Student__c
            ORDER BY COUNT(Id) DESC
            LIMIT :n
        ];

        return results;
    }
}