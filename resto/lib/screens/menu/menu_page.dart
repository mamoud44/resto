import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resto/models/category_model.dart';
import 'package:resto/models/menu_model.dart' show MenuItem;
import 'package:resto/providers/menu_provider.dart';
import 'package:resto/routes/app_routes.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    menuProvider.loadCategories();
    menuProvider.loadMenu();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final categories = menuProvider.categories;
    final menus = selectedCategoryId == null
        ? menuProvider.items
        : menuProvider.filterByCategory(selectedCategoryId!);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildStickyCategoryBar(categories),
          _buildSectionTitle("Plats disponibles"),
          _buildMenuGrid(menus),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.red.shade700,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.maxHeight <= kToolbarHeight + 40;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/images/real/breakfast.jpg",
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black.withOpacity(0.5)),
              Positioned(
                left: 16,
                bottom: 20,
                child: AnimatedOpacity(
                  opacity: isCollapsed ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    "Savourez l’excellence culinaire 🍽️",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverPersistentHeader _buildStickyCategoryBar(List<Category> categories) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 70,
        maxHeight: 70,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final category = isAll ? null : categories[index - 1];
              final isSelected = isAll
                  ? selectedCategoryId == null
                  : selectedCategoryId == category!.id;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 10,
                ),
                child: ChoiceChip(
                  label: Text(isAll ? "Tous" : category!.name),
                  selected: isSelected,
                  selectedColor: Colors.red[600],
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedCategoryId = isAll ? null : category!.id;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverPadding _buildMenuGrid(List<MenuItem> menus) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = menus[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.menuDetail,
                arguments: item,
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.price} FCFA",
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "⏱ ${item.formattedPreparationTime}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: menus.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
