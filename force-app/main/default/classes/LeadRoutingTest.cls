@IsTest
private class LeadRoutingTest {

    @IsTest
    static void hotLeadCreatesCaseAndTask() {
        Lead l = new Lead(
            LastName = 'Test', Company = 'Acme',
            Rating__c = 'Hot', Industry = 'Technology'
        );
        Test.startTest();
        insert l;
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Case WHERE Description LIKE :('%' + l.Id + '%')]);
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhoId = :l.Id]);
    }

    @IsTest
    static void warmLeadCreatesNothing() {
        Lead l = new Lead(
            LastName = 'Warm', Company = 'Beta',
            Rating__c = 'Warm', Industry = 'Retail'
        );
        Test.startTest();
        insert l;
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhoId = :l.Id]);
    }

    @IsTest
    static void bulkInsertWithinLimits() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                LastName = 'Bulk' + i, Company = 'Co' + i,
                Rating__c = 'Hot', Industry = 'Finance'
            ));
        }
        Test.startTest();
        insert leads;
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Task WHERE Subject LIKE 'Call hot lead%']);
    }
}
