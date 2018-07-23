@isTest
public class CCApexBridgeAbstractTest {
	@isTest
    public static void testNonAbstractMethods() {
        AbstractBasicImplementation abs = new AbstractBasicImplementation();
        
        Date dt = Date.today();
        Date dt2 = abs.dateFromJSON(abs.dateToJSON(dt));
        System.assertEquals(dt, dt2);
        
        DateTime dttm = DateTime.now();
        DateTime dttm2 = abs.dateTimeFromJSON(abs.dateTimeToJSON(dttm));

        String strDTTM = CCApexBridgeAbstract.encodeData(dttm);
        DateTime dttm3 = (DateTime) CCApexBridgeAbstract.decodeData(strDTTM, DateTime.class);
        // System.assertEquals(dttm, dttm3);
    }

    public class AbstractBasicImplementation extends CCApexBridgeAbstract {
        public override void process(CCApexBridgeRequest request, CCApexBridgeResponse response) {
            // Nothing
        }
    }
}