
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../questions/models/question_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get stats from Cloud Function
      final callable = FirebaseFunctions.instance.httpsCallable('getAdminStats');
      final result = await callable.call();

      setState(() {
        _stats = result.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _firestoreService.adminGetAllUsers();
      setState(() => _users = users);
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated && !state.user.isAdmin) {
          return const Scaffold(
            body: Center(
              child: Text('❌ Unauthorized: Admin access required'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('🎛️ لوحة التحكم'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                },
              ),
            ],
          ),
          drawer: _buildDrawer(),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Overview'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people),
          label: Text('Users'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.question_answer),
          label: Text('Questions'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.analytics),
          label: Text('Analytics'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildUsers();
      case 2:
        return _buildQuestions();
      case 3:
        return _buildAnalytics();
      case 4:
        return _buildSettings();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'المستخدمين',
                _stats['totalUsers']?.toString() ?? '0',
                Icons.people,
                const Color(0xFF6C63FF),
              ),
              _buildStatCard(
                'الأسئلة',
                _stats['totalQuestions']?.toString() ?? '0',
                Icons.question_answer,
                const Color(0xFF00BFA6),
              ),
              _buildStatCard(
                'الاختبارات',
                _stats['totalQuizzes']?.toString() ?? '0',
                Icons.quiz,
                const Color(0xFFFF6584),
              ),
              _buildStatCard(
                'الإيرادات',
                '\$${_stats['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}',
                Icons.attach_money,
                const Color(0xFFF39C12),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue Chart
          _buildRevenueChart(),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إيرادات الشهر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 450, const Color(0xFF6C63FF)),
                    _buildBarGroup(1, 650, const Color(0xFF6C63FF)),
                    _buildBarGroup(2, 800, const Color(0xFF6C63FF)),
                    _buildBarGroup(3, 550, const Color(0xFF6C63FF)),
                    _buildBarGroup(4, 900, const Color(0xFF6C63FF)),
                    _buildBarGroup(5, 750, const Color(0xFF6C63FF)),
                    _buildBarGroup(6, 600, const Color(0xFF6C63FF)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'آخر النشاطات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF27AE60),
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: const Text('اشتراك جديد'),
              subtitle: const Text(r'Premium Yearly - $49.99'),
              trailing: Text('2m ago'),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF6C63FF),
                child: Icon(Icons.person_add, color: Colors.white),
              ),
              title: const Text('مستخدم جديد'),
              subtitle: const Text('Ahmed Mohamed'),
              trailing: Text('5m ago'),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFF6584),
                child: Icon(Icons.quiz, color: Colors.white),
              ),
              title: const Text('اختبار مكتمل'),
              subtitle: const Text('Score: 95% - 50 questions'),
              trailing: Text('10m ago'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsers() {
    return FutureBuilder(
      future: _loadUsers(),
      builder: (context, snapshot) {
        if (_users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المستخدمين',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('تصدير'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: DataTable2(
                    columns: const [
                      DataColumn2(label: Text('المستخدم'), size: ColumnSize.L),
                      DataColumn2(label: Text('البريد')),
                      DataColumn2(label: Text('الحالة')),
                      DataColumn2(label: Text('النقاط')),
                      DataColumn2(label: Text('الإجراءات')),
                    ],
                    rows: _users.map((user) => DataRow2(
                      cells: [
                        DataCell(Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                user['photoUrl'] ?? 
                                'https://ui-avatars.com/api/?name=${user['name']}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(user['name'] ?? 'Unknown'),
                          ],
                        )),
                        DataCell(Text(user['email'] ?? '')),
                        DataCell(
                          Chip(
                            label: Text(
                              user['isPremium'] == true ? 'Premium' : 'Free',
                            ),
                            backgroundColor: user['isPremium'] == true
                                ? const Color(0xFF27AE60).withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        DataCell(Text('${user['totalPoints'] ?? 0}')),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editUser(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.block),
                              onPressed: () => _blockUser(user['id']),
                            ),
                          ],
                        )),
                      ],
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الأسئلة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddQuestionDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة سؤال'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Questions list will be implemented here
          const Center(
            child: Text('Questions management coming soon...'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التحليلات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPieChart(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('توزيع المستخدمين'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 70,
                      title: 'Free 70%',
                      color: const Color(0xFF636E72),
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: 'Premium 30%',
                      color: const Color(0xFF6C63FF),
                      radius: 90,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإعدادات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            'إعدادات الإعلانات',
            'تعديل إعدادات AdMob',
            Icons.ad_units,
            () {},
          ),
          _buildSettingsCard(
            'إعدادات الدفع',
            'تعديل إعدادات Paymob',
            Icons.payment,
            () {},
          ),
          _buildSettingsCard(
            'إعدادات النقاط',
            'تعديل نظام المكافآت',
            Icons.card_giftcard,
            () {},
          ),
          _buildSettingsCard(
            'سجلات الأمان',
            'عرض سجلات Admin Logs',
            Icons.security,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6C63FF)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المستخدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Premium'),
              value: user['isPremium'] == true,
              onChanged: (value) async {
                try {
                  final callable = FirebaseFunctions.instance.httpsCallable('adminTogglePremium');
                  await callable.call({
                    'userId': user['id'],
                    'isPremium': value,
                    'planType': value ? 'monthly' : null,
                  });
                  Navigator.pop(context);
                  _loadUsers();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _blockUser(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حظر المستخدم'),
        content: const Text('هل أنت متأكد من حظر هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement block logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حظر'),
          ),
        ],
      ),
    );
  }

  void _showAddQuestionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة سؤال جديد'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'نص السؤال'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'الفئة'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'الخيارات (مفصولة بفاصلة)'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'الإجابة الصحيحة (رقم)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement add question logic
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
