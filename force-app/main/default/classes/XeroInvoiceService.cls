public class XeroInvoiceService {

	public class LineItems {
		public String ItemCode;
		public String Description;
		public String Quantity;
		public String UnitAmount;
		public String TaxType;
		public String TaxAmount;
		public String LineAmount;
		public String AccountCode;
		public List<Tracking> Tracking;
	}

	public class Tracking {
		public String TrackingCategoryID;
		public String Name;
		public String Option;
	}

	public List<Invoices> Invoices;

	public class Invoices {
		public String Type;
		public Contact Contact;
		public String DateString;
		public String DueDateString;
		public String ExpectedPaymentDate;
		public String InvoiceNumber;
		public String Reference;
		public String BrandingThemeID;
		public String Url;
		public String CurrencyCode;
		public String Status;
		public String LineAmountTypes;
		public String SubTotal;
		public String TotalTax;
		public String Total;
		public List<LineItems> LineItems;
	}

	public class Contact {
		public String ContactID;
	}

	
	public static XeroInvoiceService parse(String json) {
		return (XeroInvoiceService) System.JSON.deserialize(json, XeroInvoiceService.class);
	}
}