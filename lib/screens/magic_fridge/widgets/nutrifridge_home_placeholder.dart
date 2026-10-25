import 'package:flutter/material.dart';

/// Clean, responsive NutriFridge destination placeholder screen
/// representing the smart fridge inventory & meal planning dashboard.
class NutriFridgeHomePlaceholder extends StatelessWidget {
  final double enterProgress; // 0.0 to 1.0

  const NutriFridgeHomePlaceholder({super.key, this.enterProgress = 1.0});

  @override
  Widget build(BuildContext context) {
    final curved = Curves.easeOutCubic.transform(enterProgress.clamp(0.0, 1.0));

    return Opacity(
      opacity: curved,
      child: Transform.scale(
        scale: 0.96 + 0.04 * curved,
        child: Container(
          color: const Color(0xFFF4F7F4), // Fresh soft sage background
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. App Top Header Bar
                _buildHeader(),

                // 2. Scrollable Dashboard Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting & Slogan
                        const Text(
                          'Good morning, Chef! 🥗',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF558B2F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your fridge, smarter.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            color: Color(0xFF20542C),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stats Highlights Row
                        _buildStatsRow(),
                        const SizedBox(height: 20),

                        // Fresh Ingredients Section Header
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'In Your Magic Fridge',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF20542C),
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EFE9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'View All (14)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Inventory Grid Cards
                        _buildInventoryGrid(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Navigation Mockup
                _buildBottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7F4),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EFE9), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Image.asset(
                  'assets/images/magic_fridge/nutrifridge_app_icon.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.kitchen_rounded,
                    color: Color(0xFF2E7D32),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Nutri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF20542C),
                            letterSpacing: -0.4,
                          ),
                        ),
                        TextSpan(
                          text: 'Fridge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF76A04B),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA7D7A5), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('14', 'Fresh', const Color(0xFF43A047))),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('3', 'Expiring', const Color(0xFFFF9800)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('8', 'Recipes', const Color(0xFF2E7D32)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EFE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF78909C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    final items = [
      {
        'name': 'Organic Avocado',
        'qty': '3 count',
        'status': 'Fresh',
        'color': const Color(0xFF558B2F),
        'asset': 'assets/images/magic_fridge/ingredient_avocado.png',
      },
      {
        'name': 'Roma Tomatoes',
        'qty': '5 units',
        'status': 'Ripe',
        'color': const Color(0xFFE53935),
        'asset': 'assets/images/magic_fridge/ingredient_tomato.png',
      },
      {
        'name': 'Broccoli Crown',
        'qty': '1 floret',
        'status': 'Fresh',
        'color': const Color(0xFF43A047),
        'asset': 'assets/images/magic_fridge/ingredient_broccoli.png',
      },
      {
        'name': 'Meyer Lemons',
        'qty': '4 count',
        'status': 'Citrus',
        'color': const Color(0xFFFBC02D),
        'asset': 'assets/images/magic_fridge/ingredient_lemon.png',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EFE9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    item['asset'] as String,
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        size: 15,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['status'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: item['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item['name'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                item['qty'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF90A4AE),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EFE9), width: 1.0)),
      ),
      child: Row(
        children: const [
          Expanded(
            child: _NavItem(
              icon: Icons.kitchen_rounded,
              label: 'Fridge',
              selected: true,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.calendar_today_rounded,
              label: 'Plan',
              selected: false,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.menu_book_rounded,
              label: 'Recipes',
              selected: false,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.shopping_basket_rounded,
              label: 'Grocery',
              selected: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF2E7D32) : const Color(0xFF90A4AE);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
