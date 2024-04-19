
## pre-requirements to in-place OS upgrade (migration)

The following highlights pre-requirements to performing an in-place OS upgrade (migration).

Testing requirements:

1) TEST/QA environment for each respective app/project 

2) App/Project feature and integration tests are defined for app/project validation regression/interop/integration testing

    2.1) in a mature test env, such tests are usually available in repeatable/automatable format via test automation and can readily be executed within a defined env via CI jobs/pipelines (jenkins, gitlab, bamboo, circleci, travisci, github actions, etc) with possible cross-browser front-end UI automations (selenium, browserstack, etc)

3) App/Project owners and/or test engineering team identified as responsible for :

    3.1) running app/project testing/validation

    3.2) development for possible app/project enhancements required for migration if necessary

    3.3) sign-off on in-place OS upgrade migration testing/validation success


## in-place OS upgrades testing process overview

The in-place OS upgrades testing process overview:

1) Validation that each project RHEL7 TEST/QA env passes all tests before migration, 

2) prepare pre-upgrade/migration VM snapshots for rollback usage in subsequent steps

3) perform the upgrade/migration in each respective TEST/QA env and

4) verify that all the RHEL package / library requirements for each app/project are met in the OS upgrade process and pass all application tests/validations/verifications thoroughly 

4.1) if not, prepare fix to resolve and rollback the respective VM to the RHEL7 snapshot state and re-run the upgrade/migration 

4.2) and apply the fix to and validate if the fix fully resolved any upgrade/migration related issues

4.3) if not, then repeat 3.1-3.2 until fully resolved

5) upon successful upgrade/migration testing then perform the upgrade/migration in the respective app/project PROD env and run post upgrade/migration app/project tests to validate success in PROD


This process enables:

1) ability to have insight of things that will break due to the in-place OS upgrade/migration in lower envs before getting to the PROD env. 

2) set of upgrade/migration related app/project patches/fixes that are required in order to successfully upgrade/migrate to the new OS version.

3) set of 3rd party SW upgrades, patches, etc required

3.1) ability to test any required component SW upgrades necessary/required for the OS upgrade/migration before getting to PROD and

3.2) any corresponding downstream app/project upgrades/enhancements/configuration updates required in lower env 

4) insight to any potential interop issues and required updates/fixes between newer component versions and other interfaces

5) ability to add /update any test cases impacted/necessitated by the OS upgrade/migration 

e.g., 

in formal /stringent PROD environments, there are almost always lower/test envs for each app/project

 

apply the in-place OS upgrade/migration to each lower test env in the prior dev lifecycle iteration. 

 

E.g., perform os-upgrade and testing validation at least 1 iteration/week in advance of the PROD upgrade/migration, but in a well planned/defined project lifecycle setting, this is usually performed at least 2-3 iterations before the actual PROD upgrade to allow enough time to fully shake-out and address any/all corresponding fixes and/or component upgrades and respective testing necessary.

 

then perform validation and upgrade/mitigation and resolution for any issues found and re-test the upgrade/migration

after all validations/tests have been passed, then apply the upgrade/migration and respective post upgrade enhancements in the PROD env

 

In summary, if treating the in-place OS upgrade/migration procedure as a first-class citizen, the same test-driven-development approach/ process/ treatment / discipline can be vigorously employed/applied as with any app/project enhancement and receive all the residual benefits from such treatment/process; chiefly, with stability and predictability with minimized chances of surprises when upgrading the PROD env.

