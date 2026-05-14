/// KL16 Garage Pro — all user-facing strings in one place.
/// Update here for i18n readiness; never hard-code copy in widgets.
class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'KL16 Garage Pro';
  static const String appTagline = 'Premium Vehicle Detailing';
  static const String appVersion = '1.0.0';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String resetPasswordSent =
      'Password reset link sent to your email.';
  static const String rememberMe = 'Remember Me';
  static const String welcomeBack = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue';
  static const String loggingIn = 'Logging in…';
  static const String logoutConfirm = 'Are you sure you want to logout?';

  // ── Roles ─────────────────────────────────────────────────────────────────
  static const String admin = 'Admin';
  static const String staff = 'Staff';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String totalVehicles = 'Total Vehicles';
  static const String completed = 'Completed';
  static const String pending = 'Pending';
  static const String todayRevenue = 'Today Revenue';
  static const String totalRevenue = 'Total Revenue';
  static const String profit = 'Profit';
  static const String noServicesToday = 'No Services Today';
  static const String noServicesTodaySubtitle =
      'Tap the + button to add your first service for today.';

  // ── Add Customer / Service ────────────────────────────────────────────────
  static const String addCustomer = 'Add Customer';
  static const String editService = 'Edit Service';
  static const String customerDetails = 'Customer Details';
  static const String customerName = 'Customer Name';
  static const String vehicleNumber = 'Vehicle Number';
  static const String contactNumber = 'Contact Number';
  static const String vehicleType = 'Vehicle Type';
  static const String selectServices = 'Select Services';
  static const String paymentSection = 'Payment';
  static const String totalAmount = 'Total Amount (RM)';
  static const String advanceAmount = 'Advance Amount (RM)';
  static const String balanceAmount = 'Balance Amount';
  static const String paymentStatus = 'Payment Status';
  static const String paymentMethod = 'Payment Method';
  static const String beforePhotos = 'Before Photos';
  static const String afterPhotos = 'After Photos';
  static const String comments = 'Additional Notes';
  static const String saveCustomer = 'Save Service';
  static const String cancel = 'Cancel';
  static const String addPhoto = 'Add Photo';

  // ── Payment status labels ─────────────────────────────────────────────────
  static const String statusCompleted = 'Completed';
  static const String statusPartial = 'Partial';
  static const String statusPending = 'Pending';

  // ── Payment methods ───────────────────────────────────────────────────────
  static const String methodUpi = 'UPI';
  static const String methodCash = 'Cash';
  static const String methodBoth = 'Both';

  // ── Vehicle types ─────────────────────────────────────────────────────────
  static const List<String> vehicleTypes = [
    'Hatchback',
    'Sedan',
    'SUV',
    'Bike',
    'Luxury Car',
    'Sports Car',
    'EV',
    'MPV',
    'Pickup Truck',
  ];

  // ── Services list ─────────────────────────────────────────────────────────
  static const List<String> serviceOptions = [
    'Body Wash',
    'Full Wash',
    'Interior Cleaning',
    'Exterior Polishing',
    'Ceramic Coating',
    'Wax Polish',
    'Engine Bay Cleaning',
    'Seat Shampoo',
    'Underbody Wash',
    'Vacuum Cleaning',
    'Headlight Restoration',
    'Water Spot Removal',
    'Foam Wash',
    'Premium Detailing',
    'Bike Detailing',
  ];

  // ── Expense categories ────────────────────────────────────────────────────
  static const List<String> expenseCategories = [
    'Cleaning Materials',
    'Salary',
    'Electricity',
    'Water',
    'Maintenance',
    'Fuel',
    'Equipment',
    'Miscellaneous',
  ];

  // ── Today screen ─────────────────────────────────────────────────────────
  static const String todayServices = "Today's Services";
  static const String searchVehicle = 'Search vehicle or customer…';
  static const String swipeToComplete = 'Swipe right to complete';

  // ── Expenses ──────────────────────────────────────────────────────────────
  static const String expenses = 'Expenses';
  static const String addExpense = 'Add Expense';
  static const String expenseCategory = 'Category';
  static const String expenseTitle = 'Title';
  static const String expenseAmount = 'Amount (RM)';
  static const String expenseNotes = 'Notes (optional)';
  static const String todayExpenses = "Today's Expenses";
  static const String noExpenses = 'No expenses recorded today.';

  // ── Staff management ──────────────────────────────────────────────────────
  static const String staff_ = 'Staff';
  static const String addStaff = 'Add Staff';
  static const String editStaff = 'Edit Staff';
  static const String staffName = 'Full Name';
  static const String staffPhone = 'Phone Number';
  static const String staffEmail = 'Email Address (optional)';
  static const String monthlySalary = 'Monthly Salary (RM)';
  static const String joinDate = 'Join Date';
  static const String emergencyContact = 'Emergency Contact Number';
  static const String uploadPhoto = 'Upload Photo';
  static const String noStaff = 'No staff members found.';

  // ── Attendance ────────────────────────────────────────────────────────────
  static const String attendance = 'Attendance';
  static const String present = 'Present';
  static const String absent = 'Absent';
  static const String late = 'Late';
  static const String markAttendance = 'Mark Attendance';
  static const String attendanceSaved = 'Attendance saved successfully.';

  // ── Analytics ─────────────────────────────────────────────────────────────
  static const String analytics = 'Analytics';
  static const String revenue = 'Revenue';
  static const String todayProfit = 'Today Profit';
  static const String weeklyProfit = 'Weekly Profit';
  static const String monthlyProfit = 'Monthly Profit';
  static const String todayExpense = 'Today Expense';
  static const String weeklyExpense = 'Weekly Expense';
  static const String monthlyExpense = 'Monthly Expense';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String notifications = 'Notifications';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String appVersionLabel = 'App Version';
  static const String backupData = 'Backup Data';
  static const String userManagement = 'User Management';
  static const String securitySettings = 'Security Settings';

  // ── Common actions ────────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String confirm = 'Confirm';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String retry = 'Retry';
  static const String loading = 'Loading…';
  static const String search = 'Search…';
  static const String filter = 'Filter';
  static const String all = 'All';
  static const String exportPdf = 'Export PDF';
  static const String shareWhatsApp = 'Share on WhatsApp';
  static const String generateQr = 'Generate QR';

  // ── Validation ────────────────────────────────────────────────────────────
  static const String fieldRequired = 'This field is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String invalidAmount = 'Please enter a valid amount.';
  static const String passwordMinLength =
      'Password must be at least 6 characters.';
  static const String advanceExceedsTotal =
      'Advance cannot exceed total amount.';

  // ── Errors ────────────────────────────────────────────────────────────────
  static const String somethingWentWrong = 'Something went wrong. Try again.';
  static const String noInternet = 'No internet connection.';
  static const String permissionDenied = 'Permission denied.';
  static const String sessionExpired =
      'Session expired. Please login again.';

  // ── Success ───────────────────────────────────────────────────────────────
  static const String savedSuccessfully = 'Saved successfully!';
  static const String deletedSuccessfully = 'Deleted successfully!';
  static const String updatedSuccessfully = 'Updated successfully!';

  // ── Offline ───────────────────────────────────────────────────────────────
  static const String offlineMode = 'Offline Mode — showing cached data';
}
