class ApiUrl {
  // ! BASE URL
  static String baseUrlGlobal = 'http://124.123.122.112:7081/ReportNew';
    // static String baseUrlGlobal = 'http://124.123.122.112:7081/Report';

  // ! LOGIN API
  static const String loginApi = '/Login';
  static const String updateFCMId = '/LogOut';
  static const String updatePwd = '/UpdatePwd';

  // ! Common API
  static const String saveBaseURL = '/SaveBaseURL';
  // static const String getBaseUrl = 'http://124.123.122.112:7081/ReportNew/GetBaseUrl';
  static const String getNotificationLogs = '/GetNotificationLogs';
  static const String updateNotificationLogsSingle =
      '/UpdateNotificationLogsSingle';

  // ! FINANCE MODULE API
  static const String getVoucherApprovalDashboard =
      '/GetVoucherApprovalDashboard';
  static const String getAuthorisationList = '/GetAuthorisationList';
  static const String authoriseVoucher = '/AuthoriseFinanceVoucher';
  static const String getAuthorisationListFilter =
      '/GetAuthorisationListFilter';
  static const String getAllAuthorisationList = '/GetAllAuthorisationList';
  static const String getHoldVoucher = '/GetHoldFinance';
  // http://124.123.122.112:7081/Report/GetHoldFinance?mUser=Mihir&mUserLevel=3&MainType=Bank Payment

  // ! Get PDF Report
  static const String getVoucherReport = '/getBankpaymentReport';
  static const String downloadComparisonPdf = '/DownloadComparisonPdf';

  // ! Production Module
  static const String getProductionRights = '/GetProductionRights';
  static const String submitHourlyProductionEntry =
      '/SubmitHourlyProductionEntry';
  static const String getHourlyReportData = '/GetHourlyReportData';
  static const String submitDaywiseProductionEntry =
      '/SubmitDaywiseProductionEntry';
  static const String getDaywiseReport = '/GetDaywiseReport';

  // ! LG30 Pilger Module
  static const String getMachinesByDepartment = '/GetMachinesByDepartment';
  static const String submitLG35PilgerEntry =
      '/SubmitLG35PilgerProductionEntry';
  static const String getReportLG35Pilger = '/GetReportLG35Pilger';

  // ! Daily Production
  static const String getCapacityReport = '/GetCapacityReport';
  static const String submitCapacityEntry = '/SubmitCapacityEntry';

  // ! FFD Forming Production
  static const String getFFDReport = '/GetFFDReport';
  static const String submitFFDEntry = '/SubmitFFDEntry';
}
