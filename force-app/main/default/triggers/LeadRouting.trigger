trigger LeadRouting on Lead (after insert, after update) {
    List<Lead> toRoute = new List<Lead>();

    for (Lead l : Trigger.new) {
        Boolean isHot = l.Rating__c == 'Hot' && l.Industry != null;
        if (!isHot) {
            continue;
        }
        if (Trigger.isUpdate) {
            Lead old = Trigger.oldMap.get(l.Id);
            if (old.Rating__c == 'Hot' && old.Industry != null) {
                continue; // already routed
            }
        }
        toRoute.add(l);
    }

    if (!toRoute.isEmpty()) {
        LeadRoutingHandler.route(toRoute);
    }
}
