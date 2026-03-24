import 'package:flutter/material.dart';

class AdminArtistsAlbumsPage extends StatelessWidget {
  const AdminArtistsAlbumsPage({super.key});

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
          // Main Content Tabs (Mocking a tab view with a single column for now)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildArtistsSection(),
                ),
                if (isDesktop) const SizedBox(width: 32),
                if (isDesktop)
                  Expanded(
                    flex: 1,
                    child: _buildAlbumsSection(),
                  ),
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
        Text('CATALOG > ARTISTS & ALBUMS', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Artist & Album Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 4),
        Text('Curate and override global artist and album information', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF61440C), foregroundColor: const Color(0xFFE5E2E1), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          label: const Text('New Artist'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD79B), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          onPressed: () {},
          icon: const Icon(Icons.album),
          label: const Text('New Album'),
        ),
      ],
    );
  }

  Widget _buildArtistsSection() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Global Artists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A).withOpacity(0.5)),
                  columns: const [
                    DataColumn(label: Text('ARTIST', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('ALBUMS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  ],
                  rows: [
                    _buildArtistRow('Minh Tú', 'Active', Colors.greenAccent, '3'),
                    _buildArtistRow('Neon Architect', 'Verified', const Color(0xFFA4E7FF), '1'),
                    _buildArtistRow('The Void Collective', 'Inactive', Colors.grey, '5'),
                    _buildArtistRow('Luna V', 'Active', Colors.greenAccent, '2'),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlbumsSection() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Curated Albums', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A).withOpacity(0.5)),
                  columns: const [
                    DataColumn(label: Text('ALBUM NAME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('ARTIST', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('TAGS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  ],
                  rows: [
                    _buildAlbumRow('City Lights Vol. 1', 'Minh Tú', ['Vietnamese Hot', 'Trending']),
                    _buildAlbumRow('Electric Dreams (EP)', 'Neon Architect', ['New Release']),
                    _buildAlbumRow('Minimalist Theory', 'The Void Collective', ['Indie Focus']),
                    _buildAlbumRow('Silent Skyline', 'Luna V', ['Trending']),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildArtistRow(String name, String status, Color statusColor, String albumCount) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFF353534), child: Icon(Icons.person, size: 16, color: Colors.white24)),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        )),
        DataCell(Text(albumCount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.grey, size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () {}),
          ],
        )),
      ],
    );
  }

  DataRow _buildAlbumRow(String title, String artist, List<String> tags) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF353534), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.album, size: 16, color: Colors.white24)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        )),
        DataCell(Text(artist, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500))),
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
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20), onPressed: () {}),
          ],
        )),
      ],
    );
  }
}
