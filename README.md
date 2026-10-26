# Salesforce Lead-to-Case Automation with Integration Checks

A small Salesforce setup that routes high-priority leads into Cases and
creates follow-up Tasks, plus an integration check that verifies an external
REST endpoint before data is sent.

## What it does

1. When a Lead's `Rating__c` is `Hot` and `Industry` is set, an Apex trigger
   creates a Case linked to the Lead.
2. A Task is created for the Lead owner, due in 2 days.
3. `scripts/integration_check.py` calls an external REST endpoint, validates
   the response shape, and logs pass/fail for each check.

## Status

Code is written and structured for a Salesforce Developer Edition org. It has not yet been deployed or run against a live org; the integration check was tested against a public API endpoint only.

## Setup

1. Create a free Salesforce Developer Edition org.
2. Add the custom field `Rating__c` (Picklist on Lead: Hot, Warm, Cold).
3. Deploy `force-app/main/default/triggers/LeadRouting.trigger` and its handler.
4. Run the tests in `force-app/main/default/classes/LeadRoutingTest.cls`.
5. Run the integration check:

   ```bash
   python scripts/integration_check.py --base-url https://jsonplaceholder.typicode.com
   ```

## Configuration record

| Object | Field / Rule        | Purpose                                  |
|--------|---------------------|------------------------------------------|
| Lead   | Rating__c (Picklist)| Drives routing                           |
| Case   | Origin = Web        | Set on every routed case                 |
| Task   | ActivityDate +2 days| Follow-up reminder for lead owner        |

## Test coverage

- Hot lead with industry creates one Case and one Task.
- Warm lead creates nothing.
- Bulk insert of 200 leads stays within governor limits.
- Integration check catches a wrong status code and a missing field.

## Next steps

- Add a Flow version of the same routing for admins without Apex.
- Add Slack notification on Case creation.
