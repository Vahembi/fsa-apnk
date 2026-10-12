import 'package:flutter/material.dart';

void main() => runApp(const FsaApp());

const navy = Color(0xFF14213D);
const blue = Color(0xFF2457C5);
const green = Color(0xFF16835B);
const background = Color(0xFFF4F6FA);

class FsaApp extends StatelessWidget {
  const FsaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FSA APNK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: blue),
        appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
      home: const FsaHome(),
    );
  }
}

class Member {
  Member(this.name, this.department, {this.paid = false});
  final String name;
  final String department;
  bool paid;
}

class Assistance {
  Assistance(this.name, this.reason, this.amount, this.date);
  final String name, reason, date;
  final int amount;
}

class FsaHome extends StatefulWidget {
  const FsaHome({super.key});
  @override
  State<FsaHome> createState() => _FsaHomeState();
}

class _FsaHomeState extends State<FsaHome> {
  int tab = 0;
  final members = <Member>[
    Member('Mzee MWANAHEWA', 'Administration', paid: true),
    Member('Me Ndugo Ndovya', 'Administration', paid: true),
    Member('Maman Lucie Kisolomi', 'Administration', paid: true),
    Member('Papa Denis', 'Administration', paid: true),
    Member('Grâce Kavugho', 'Finances'),
    Member('Serge Musafiri', 'Administration'),
  ];
  final assistances = <Assistance>[
    Assistance('Mzee MWANAHEWA', 'Mariage', 150000, 'Mars 2026'),
    Assistance('Me Ndugo Ndovya', 'Maladie / opération', 150000, 'Mars 2026'),
    Assistance('Maman Lucie Kisolomi', 'Maladie chronique', 150000, 'Mars 2026'),
    Assistance('Papa Denis', 'Décès', 510000, 'Mars 2026'),
  ];
  final operations = <Map<String, String>>[
    {'date': 'Mars 2026', 'label': 'Solde antérieur', 'type': 'Entrée', 'amount': '220 000 FC'},
    {'date': 'Mars 2026', 'label': 'Cotisations FSA', 'type': 'Entrée', 'amount': '880 000 FC'},
    {'date': 'Mars 2026', 'label': 'Solidarité Maman Nathalie', 'type': 'Entrée', 'amount': '272 000 FC'},
    {'date': 'Mars 2026', 'label': 'Assistances sociales', 'type': 'Sortie', 'amount': '960 000 FC'},
  ];

  int get totalAvailable => 220000 + 880000 + 272000;
  int get totalAssistance => assistances.fold(0, (s, a) => s + a.amount);
  int get balance => totalAvailable - totalAssistance;
  String money(int n) => '${n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FC';

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      _membersPage(),
      _assistancePage(),
      _operationsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FSA APNK', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Fonds Social des Agents', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
        ]),
        actions: [
          IconButton(tooltip: 'Ajouter', onPressed: _quickAdd, icon: const Icon(Icons.add_circle_outline)),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Membres'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism), label: 'Assistances'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Opérations'),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final paid = members.where((m) => m.paid).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [navy, blue]), borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SOLDE DISPONIBLE', style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 12)),
          const SizedBox(height: 8),
          Text(money(balance), style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Situation financière • Mars 2026', style: TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.35,
        children: [
          _stat('Fonds disponibles', money(totalAvailable), Icons.account_balance_wallet, blue),
          _stat('Assistances', money(totalAssistance), Icons.volunteer_activism, green),
          _stat('Membres enregistrés', '${members.length}', Icons.groups, const Color(0xFF805AD5)),
          _stat('Cotisations payées', '$paid / ${members.length}', Icons.fact_check, const Color(0xFFB7791F)),
        ],
      ),
      const SizedBox(height: 22),
      _sectionTitle('Accès rapide'),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _quickCard('Ajouter membre', Icons.person_add_alt_1, () => _showMemberForm())),
        const SizedBox(width: 10),
        Expanded(child: _quickCard('Enregistrer une aide', Icons.volunteer_activism, () => _showAssistanceForm())),
      ]),
      const SizedBox(height: 22),
      _sectionTitle('Dernières opérations'),
      const SizedBox(height: 8),
      ...operations.reversed.take(3).map((op) => _operationTile(op)),
      const SizedBox(height: 8),
      const Text('Prototype de démonstration : les données affichées sont locales et préchargées.', style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]);
  }

  Widget _stat(String title, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE5E9F1))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(icon, color: color, size: 25),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      Text(title, style: const TextStyle(color: Colors.black54, fontSize: 11)),
    ]),
  );

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy));
  Widget _quickCard(String title, IconData icon, VoidCallback action) => InkWell(
    onTap: action,
    borderRadius: BorderRadius.circular(16),
    child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E9F1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: blue, size: 28), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w600))])),
  );

  Widget _membersPage() => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [Expanded(child: _sectionTitle('Membres')), FilledButton.icon(onPressed: _showMemberForm, icon: const Icon(Icons.add), label: const Text('Ajouter'))]),
    const SizedBox(height: 8),
    Text('${members.length} membres dans cette démonstration', style: const TextStyle(color: Colors.black54)),
    const SizedBox(height: 12),
    ...members.map((m) => Card(color: Colors.white, child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFE8EEFF), child: Text(m.name.isNotEmpty ? m.name[0] : '?', style: const TextStyle(color: blue))),
      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(m.department),
      trailing: Switch(value: m.paid, onChanged: (v) => setState(() => m.paid = v)),
      isThreeLine: false,
    ))),
  ]);

  Widget _assistancePage() => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [Expanded(child: _sectionTitle('Assistances sociales')), IconButton(onPressed: _showAssistanceForm, icon: const Icon(Icons.add_circle, color: blue, size: 30))]),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Total des assistances enregistrées', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 6), Text(money(totalAssistance), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navy)),
    ])),
    const SizedBox(height: 12),
    ...assistances.map((a) => Card(color: Colors.white, child: ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFFE4F5ED), child: Icon(Icons.volunteer_activism, color: green)),
      title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${a.reason} • ${a.date}'),
      trailing: Text(money(a.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    ))),
  ]);

  Widget _operationsPage() => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [Expanded(child: _sectionTitle('Journal financier')), IconButton(onPressed: _showOperationForm, icon: const Icon(Icons.add_circle, color: blue, size: 30))]),
    const SizedBox(height: 8),
    const Text('Suivi des entrées et sorties de fonds', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 12),
    ...operations.reversed.map(_operationTile),
  ]);

  Widget _operationTile(Map<String, String> op) {
    final isIn = op['type'] == 'Entrée';
    return Card(color: Colors.white, child: ListTile(
      leading: CircleAvatar(backgroundColor: isIn ? const Color(0xFFE4F5ED) : const Color(0xFFFFE8E8), child: Icon(isIn ? Icons.south_west : Icons.north_east, color: isIn ? green : Colors.red)),
      title: Text(op['label']!, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${op['date']} • ${op['type']}'),
      trailing: Text(op['amount']!, style: TextStyle(fontWeight: FontWeight.bold, color: isIn ? green : Colors.red, fontSize: 12)),
    ));
  }

  void _quickAdd() => showModalBottomSheet(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: Wrap(children: [
    ListTile(leading: const Icon(Icons.person_add), title: const Text('Ajouter un membre'), onTap: () { Navigator.pop(ctx); _showMemberForm(); }),
    ListTile(leading: const Icon(Icons.volunteer_activism), title: const Text('Enregistrer une assistance'), onTap: () { Navigator.pop(ctx); _showAssistanceForm(); }),
    ListTile(leading: const Icon(Icons.receipt_long), title: const Text('Ajouter une opération'), onTap: () { Navigator.pop(ctx); _showOperationForm(); }),
  ])));

  void _showMemberForm() {
    final name = TextEditingController(), department = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nouveau membre'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom complet')),
        const SizedBox(height: 10), TextField(controller: department, decoration: const InputDecoration(labelText: 'Service / département')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')), FilledButton(onPressed: () {
        if (name.text.trim().isEmpty) return;
        setState(() => members.add(Member(name.text.trim(), department.text.trim().isEmpty ? 'Non précisé' : department.text.trim())));
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membre ajouté à la démonstration.')));
      }, child: const Text('Enregistrer'))],
    ));
  }

  void _showAssistanceForm() {
    final name = TextEditingController(), reason = TextEditingController(), amount = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nouvelle assistance'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Bénéficiaire')),
        const SizedBox(height: 10), TextField(controller: reason, decoration: const InputDecoration(labelText: 'Motif')),
        const SizedBox(height: 10), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant en FC')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')), FilledButton(onPressed: () {
        final value = int.tryParse(amount.text.replaceAll(' ', ''));
        if (name.text.trim().isEmpty || value == null || value <= 0) return;
        setState(() => assistances.add(Assistance(name.text.trim(), reason.text.trim().isEmpty ? 'Non précisé' : reason.text.trim(), value, 'À confirmer')));
        Navigator.pop(ctx);
      }, child: const Text('Enregistrer'))],
    ));
  }

  void _showOperationForm() {
    final label = TextEditingController(), amount = TextEditingController();
    String type = 'Entrée';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
      title: const Text('Nouvelle opération'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: label, decoration: const InputDecoration(labelText: 'Libellé')),
        const SizedBox(height: 10), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant en FC')),
        const SizedBox(height: 10), DropdownButtonFormField<String>(value: type, items: const [DropdownMenuItem(value: 'Entrée', child: Text('Entrée de fonds')), DropdownMenuItem(value: 'Sortie', child: Text('Sortie de fonds'))], onChanged: (v) => setLocal(() => type = v ?? 'Entrée'), decoration: const InputDecoration(labelText: 'Type')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')), FilledButton(onPressed: () {
        final value = int.tryParse(amount.text.replaceAll(' ', ''));
        if (label.text.trim().isEmpty || value == null || value <= 0) return;
        setState(() => operations.add({'date': 'À confirmer', 'label': label.text.trim(), 'type': type, 'amount': money(value)}));
        Navigator.pop(ctx);
      }, child: const Text('Enregistrer'))],
    )));
  }
}
