import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/core/network/api_client.dart';

class AdminSubscriptionsPage extends StatefulWidget {
  const AdminSubscriptionsPage({super.key});

  @override
  State<AdminSubscriptionsPage> createState() =>
      _AdminSubscriptionsPageState();
}

class _AdminSubscriptionsPageState extends State<AdminSubscriptionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Dio _dio = sl<ApiClient>().dio;

  // Stats
  Map<String, dynamic> _stats = const {};
  bool _isLoadingStats = false;

  // Subscriptions tab
  List<Map<String, dynamic>> _subscriptions = const [];
  bool _isLoadingSubs = false;
  int _subsPage = 1;
  int _subsTotalPages = 1;
  String? _subsStatusFilter;

  // Transactions tab
  List<Map<String, dynamic>> _transactions = const [];
  bool _isLoadingTxns = false;
  int _txnsPage = 1;
  int _txnsTotalPages = 1;

  // Expiring tab
  List<Map<String, dynamic>> _expiring = const [];
  bool _isLoadingExpiring = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAll() {
    _loadStats();
    _loadSubscriptions();
    _loadTransactions();
    _loadExpiring();
  }

  // ==================== DATA LOADING ====================

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final response = await _dio.get(ApiUrls.adminSubscriptionStats);
      _stats = Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Không thể tải thống kê.'));
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoadingSubs = true);
    try {
      final params = <String, dynamic>{
        'page': _subsPage,
        'pageSize': 20,
      };
      if (_subsStatusFilter != null) params['status'] = _subsStatusFilter;

      final response = await _dio.get(
        ApiUrls.adminSubscriptions,
        queryParameters: params,
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final raw = (data['items'] as List?) ?? const [];
      _subscriptions =
          raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _subsTotalPages = (data['totalPages'] as int?) ?? 1;
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Không thể tải danh sách gói.'));
    } finally {
      if (mounted) setState(() => _isLoadingSubs = false);
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTxns = true);
    try {
      final response = await _dio.get(
        ApiUrls.adminSubscriptionTransactions,
        queryParameters: {'page': _txnsPage, 'pageSize': 20},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final raw = (data['items'] as List?) ?? const [];
      _transactions =
          raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _txnsTotalPages = (data['totalPages'] as int?) ?? 1;
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Không thể tải giao dịch.'));
    } finally {
      if (mounted) setState(() => _isLoadingTxns = false);
    }
  }

  Future<void> _loadExpiring() async {
    setState(() => _isLoadingExpiring = true);
    try {
      final response = await _dio.get(
        ApiUrls.adminSubscriptionsExpiring,
        queryParameters: {'daysAhead': 10, 'page': 1, 'pageSize': 50},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final raw = (data['items'] as List?) ?? const [];
      _expiring =
          raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Không thể tải danh sách sắp hết hạn.'));
    } finally {
      if (mounted) setState(() => _isLoadingExpiring = false);
    }
  }

  // ==================== HELPERS ====================

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '—';
    final num val = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
    return '${val.toStringAsFixed(0)}đ';
  }

  Color _statusColor(String? status) {
    return switch (status) {
      'active' => const Color(0xFF4CAF50),
      'succeeded' => const Color(0xFF4CAF50),
      'expired' => const Color(0xFFFF9800),
      'cancelled' => const Color(0xFFE53935),
      'failed' => const Color(0xFFE53935),
      'pending' => const Color(0xFFFFC107),
      _ => Colors.grey,
    };
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Payment Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quản lý gói đăng ký, giao dịch thanh toán và theo dõi gói sắp hết hạn.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),

          // Stats Cards
          _buildStatsRow(),
          const SizedBox(height: 20),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFFD79B),
              labelColor: const Color(0xFFFFD79B),
              unselectedLabelColor: Colors.grey,
              dividerHeight: 0,
              tabs: [
                Tab(
                  text: 'Subscriptions (${_subscriptions.length})',
                ),
                Tab(
                  text: 'Transactions (${_transactions.length})',
                ),
                Tab(
                  text: 'Expiring Soon (${_expiring.length})',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubscriptionsTab(),
                _buildTransactionsTab(),
                _buildExpiringTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATS ROW ====================

  Widget _buildStatsRow() {
    if (_isLoadingStats) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD79B)),
        ),
      );
    }

    return Row(
      children: [
        _buildStatCard(
          'Active Subs',
          '${_stats['totalActive'] ?? 0}',
          Icons.verified_user,
          const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Expiring Soon',
          '${_stats['totalExpiringSoon'] ?? 0}',
          Icons.warning_amber_rounded,
          const Color(0xFFFF9800),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Total Revenue',
          _formatCurrency(_stats['totalRevenue']),
          Icons.attach_money,
          const Color(0xFF2196F3),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Transactions',
          '${_stats['totalTransactions'] ?? 0}',
          Icons.receipt_long,
          const Color(0xFF9C27B0),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SUBSCRIPTIONS TAB ====================

  Widget _buildSubscriptionsTab() {
    return Column(
      children: [
        // Filter row
        Row(
          children: [
            _buildFilterChip('All', null),
            const SizedBox(width: 8),
            _buildFilterChip('Active', 'active'),
            const SizedBox(width: 8),
            _buildFilterChip('Expired', 'expired'),
            const SizedBox(width: 8),
            _buildFilterChip('Cancelled', 'cancelled'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () {
                _loadSubscriptions();
                _loadStats();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isLoadingSubs
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFFFFD79B)),
                )
              : _subscriptions.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có dữ liệu.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildDataTable(
                      columns: const [
                        'User',
                        'Plan',
                        'Status',
                        'Start',
                        'End',
                        'Created',
                      ],
                      rows: _subscriptions
                          .map(
                            (s) => <String>[
                              s['username'] ?? '—',
                              s['planName'] ?? '—',
                              s['status'] ?? '—',
                              _formatDate(s['currentPeriodStart']?.toString()),
                              _formatDate(s['currentPeriodEnd']?.toString()),
                              _formatDate(s['createdAt']?.toString()),
                            ],
                          )
                          .toList(),
                      statusColumnIndex: 2,
                    ),
        ),
        _buildPagination(
          _subsPage,
          _subsTotalPages,
          (page) {
            _subsPage = page;
            _loadSubscriptions();
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _subsStatusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFFFD79B),
      backgroundColor: const Color(0xFF2A2A2A),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontSize: 12,
      ),
      side: BorderSide.none,
      onSelected: (_) {
        setState(() {
          _subsStatusFilter = status;
          _subsPage = 1;
        });
        _loadSubscriptions();
      },
    );
  }

  // ==================== TRANSACTIONS TAB ====================

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _loadTransactions,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isLoadingTxns
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFFFFD79B)),
                )
              : _transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có dữ liệu.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildDataTable(
                      columns: const [
                        'User',
                        'TxnRef',
                        'Amount',
                        'Status',
                        'Date',
                      ],
                      rows: _transactions
                          .map(
                            (t) => <String>[
                              t['username'] ?? '—',
                              t['vnpTxnRef'] ?? '—',
                              _formatCurrency(t['amount']),
                              t['status'] ?? '—',
                              _formatDate(t['createdAt']?.toString()),
                            ],
                          )
                          .toList(),
                      statusColumnIndex: 3,
                    ),
        ),
        _buildPagination(
          _txnsPage,
          _txnsTotalPages,
          (page) {
            _txnsPage = page;
            _loadTransactions();
          },
        ),
      ],
    );
  }

  // ==================== EXPIRING TAB ====================

  Widget _buildExpiringTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _loadExpiring,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isLoadingExpiring
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFFFFD79B)),
                )
              : _expiring.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có gói nào sắp hết hạn.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildDataTable(
                      columns: const [
                        'User',
                        'Plan',
                        'Status',
                        'Expires',
                        'Days Left',
                      ],
                      rows: _expiring.map((s) {
                        final endStr =
                            s['currentPeriodEnd']?.toString();
                        final end = DateTime.tryParse(endStr ?? '');
                        final daysLeft = end != null
                            ? end.difference(DateTime.now()).inDays
                            : 0;
                        return <String>[
                          s['username'] ?? '—',
                          s['planName'] ?? '—',
                          s['status'] ?? '—',
                          _formatDate(endStr),
                          '$daysLeft ngày',
                        ];
                      }).toList(),
                      statusColumnIndex: 2,
                    ),
        ),
      ],
    );
  }

  // ==================== SHARED WIDGETS ====================

  Widget _buildDataTable({
    required List<String> columns,
    required List<List<String>> rows,
    int? statusColumnIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF252525)),
          dataRowColor: WidgetStateProperty.all(Colors.transparent),
          columnSpacing: 24,
          columns: columns
              .map(
                (c) => DataColumn(
                  label: Text(
                    c,
                    style: const TextStyle(
                      color: Color(0xFFFFD79B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: rows.map((row) {
            return DataRow(
              cells: row.asMap().entries.map((entry) {
                final isStatus = entry.key == statusColumnIndex;
                final value = entry.value;
                return DataCell(
                  isStatus
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _statusColor(value).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: _statusColor(value),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination(
    int currentPage,
    int totalPages,
    ValueChanged<int> onPageChanged,
  ) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),
          Text(
            'Trang $currentPage / $totalPages',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
