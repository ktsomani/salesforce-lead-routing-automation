public with sharing class LeadRoutingHandler {

    public static void route(List<Lead> leads) {
        List<Case> cases = new List<Case>();
        List<Task> tasks = new List<Task>();

        for (Lead l : leads) {
            cases.add(new Case(
                Subject = 'Follow up: ' + l.Company,
                Origin = 'Web',
                Status = 'New',
                Description = 'Auto-routed from hot lead ' + l.Id
            ));
        }
        insert cases;

        for (Integer i = 0; i < leads.size(); i++) {
            Lead l = leads[i];
            tasks.add(new Task(
                Subject = 'Call hot lead: ' + l.Company,
                WhoId = l.Id,
                OwnerId = l.OwnerId,
                ActivityDate = Date.today().addDays(2),
                Status = 'Not Started',
                WhatId = cases[i].Id
            ));
        }
        insert tasks;
    }
}
