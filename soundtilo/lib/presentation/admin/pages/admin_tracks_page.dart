import 'package:flutter/material.dart';

class AdminTracksPage extends StatelessWidget {
  const AdminTracksPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Actions
          isDesktop ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildHeaderTitle(),
              _buildHeaderActions(),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitle(),
              const SizedBox(height: 24),
              _buildHeaderActions(),
            ],
          ),
          const SizedBox(height: 32),
          // Filters & Stats
          isDesktop ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildFiltersContainer(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildStatsContainer(),
              )
            ],
          ) : Column(
            children: [
              _buildFiltersContainer(),
              const SizedBox(height: 24),
              _buildStatsContainer(),
            ],
          ),
          const SizedBox(height: 32),
          // Data Table Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
              width: double.infinity,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A).withOpacity(0.5)),
                  columns: const [
                    DataColumn(label: Text('TRACK INFO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('ARTIST & ALBUM', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('TAGS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  ],
                  rows: [
                    _buildTrackRow('Midnight Synthesis', 'ISRC: QM-42-19-00123', 'Neon Architect', 'Electric Dreams (EP)', 'Active', const Color(0xFFA4E7FF), ['Trending', 'New Release']),
                    _buildTrackRow('Sài Gòn Chill', 'ISRC: VN-A0-24-99801', 'Minh Tú', 'City Lights Vol. 1', 'Inactive', Colors.redAccent, ['Vietnamese Hot']),
                    _buildTrackRow('Echoes of Silence', 'ISRC: US-L4-23-44091', 'The Void Collective', 'Minimalist Theory', 'Hidden', Colors.grey, ['Indie Focus']),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sticky Footer (Bulk Action Mock)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFFD79B).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.info, color: Color(0xFFFFD79B), size: 16)),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selection Mode', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('SELECT TRACKS TO PERFORM MASS ACTIONS', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Clear Selection', style: TextStyle(color: Colors.grey))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      onPressed: () {},
                      child: const Text('Deactivate Selected'),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATALOG > TRACK MANAGEMENT', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Manage Tracks', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 4),
        Text('Configure your global library and artist profiles', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
          onPressed: () {},
          icon: const Icon(Icons.layers),
          label: const Text('Bulk Update'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF61440C), foregroundColor: const Color(0xFFE5E2E1), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          label: const Text('Add Artist/Album'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD79B), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add New Track'),
        ),
      ],
    );
  }

  Widget _buildFiltersContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(width: 200, child: _buildFilterDropdown('GENRE', 'All Genres')),
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: const Color(0xFF353534), borderRadius: BorderRadius.circular(6)), child: const Text('All', style: TextStyle(color: Color(0xFFFFD79B), fontSize: 12, fontWeight: FontWeight.bold)))),
                      Expanded(child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 6), child: const Text('Active', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)))),
                      Expanded(child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 6), child: const Text('Hidden', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)))),
                    ],
                  ),
                )
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatsContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      width: double.infinity,
      child: const Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL TRACKS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              SizedBox(height: 4),
              Text('1,284', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.trending_up, color: Color(0xFFA4E7FF), size: 12),
                  SizedBox(width: 4),
                  Text('+12% this month', style: TextStyle(color: Color(0xFFA4E7FF), fontSize: 10)),
                ],
              )
            ],
          ),
          Positioned(right: -20, bottom: -20, child: Icon(Icons.library_music, size: 60, color: Colors.white10)),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        )
      ],
    );
  }

  DataRow _buildTrackRow(String title, String isrc, String artist, String album, String status, Color statusColor, List<String> tags) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF353534), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.music_note, color: Colors.white24)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(isrc, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            )
          ],
        )),
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(artist, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            Text(album, style: const TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        )),
        DataCell(Row(
          children: tags.map((t) => Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF353534), borderRadius: BorderRadius.circular(4)),
            child: Text(t, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          )).toList(),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.grey, size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.delete, color: Colors.grey, size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20), onPressed: () {}),
          ],
        )),
      ],
    );
  }
}
