import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/animated_avatar.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final booksAsync = ref.watch(booksProvider);
    final isDark = user?.isDarkMode ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(booksAsync),
              const SearchScreen(),
              const SizedBox(), // Placeholder for library tab
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    // باز کردن کتاب صوتی
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.headphones, color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildHomeTab(AsyncValue<List<Book>> booksAsync) {
    final user = ref.watch(userProfileProvider);

    return CustomScrollView(
      slivers: [
        // AppBar با انیمیشن
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      child: Text(
                        'سلام، ${user?.name ?? 'کاربر'} 👋',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'امروز چه کتابی می‌خوای بخونی؟',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            // آواتار کاربر
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: AnimatedAvatar(
                seed: user?.diceBearSeed ?? 'default',
                style: user?.avatarStyle ?? 'adventurer',
                size: 40,
                onTap: () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ),
          ],
        ),
        
        // دسته‌بندی‌ها
        SliverToBoxAdapter(
          child: FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildCategories(),
          ),
        ),
        
        // عنوان بخش
        SliverToBoxAdapter(
          child: FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'کتاب‌های جدید',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'مشاهده همه',
                      style: GoogleFonts.vazirmatn(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // لیست کتاب‌ها
        booksAsync.when(
          data: (books) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => BookCard(
                  book: books[index],
                  index: index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: books[index]),
                      ),
                    );
                  },
                ),
                childCount: books.length,
              ),
            ),
          ),
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => SliverFillRemaining(
            child: Center(child: Text('خطا: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = ['همه', 'رمان', 'تاریخی', 'علمی', 'کودک', 'مذهبی'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ZoomIn(
              delay: Duration(milliseconds: index * 100),
              child: FilterChip(
                label: Text(
                  categories[index],
                  style: GoogleFonts.vazirmatn(),
                ),
                selected: index == 0,
                onSelected: (_) {},
                backgroundColor: Colors.grey[200],
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'خانه',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'جستجو',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.library_books_rounded),
            label: 'کتابخانه من',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'پروفایل',
          ),
        ],
      ),
    );
  }
}