@isTest
public class FakeApexTest {
    // Mock Apex Test - delete once a real test class is added to this project
    // Use: to allow foce:apex:test:run to run in CI/CD until real tests are added

    @isTest
    static void fakeTest() {
        System.assert(1 == 1);
    }

}