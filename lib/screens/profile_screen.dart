import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/analytics_service.dart';
import '../services/newsletter_service.dart';
import '../services/sports_service.dart';
import '../widgets/rain_effect.dart';
import 'package:pay/pay.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _paymentItems = [
    const PaymentItem(
      label: 'Donation to Photo Poet',
      amount: '5.00',
      status: PaymentItemStatus.final_price,
    )
  ];

  late Future<PaymentConfiguration> _googlePayConfigFuture;
  final _sportsService = SportsService();
  late Future<List<TeamStanding>> _standingsFuture;

  @override
  void initState() {
    super.initState();
    _googlePayConfigFuture = _loadGooglePayConfig();
    _standingsFuture = _sportsService.getPremierLeagueStandings();
  }

  Future<PaymentConfiguration> _loadGooglePayConfig() async {
    try {
      final configString = await rootBundle.loadString('assets/google_pay_config.json');
      return PaymentConfiguration.fromJsonString(configString);
    } catch (e) {
      debugPrint('Failed to load Google Pay config: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitNewsletter() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        // Store in Firestore
        await NewsletterService.subscribe(
          email: _emailController.text,
          name: _nameController.text,
        );
        
        // Log analytics
        await AnalyticsService.logNewsletterSignup(email: _emailController.text);

        if (mounted) {
          setState(() => _isSubmitting = false);
          _nameController.clear();
          _emailController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to the inner circle!'),
              backgroundColor: Color(0xFFB08D5B),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscription failed: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171B21),
      body: Stack(
        children: [
          const Positioned.fill(child: RainEffect()),
          CustomScrollView(
            slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF171B21),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1518131672697-613add0d3364?q=80&w=2000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF171B21).withValues(alpha: 0.8),
                          const Color(0xFF171B21),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                'YOUR PROFILE',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 40),
                  _buildLikedPoemsSection(),
                  const SizedBox(height: 48),
                  _buildDonationSection(),
                  const SizedBox(height: 48),
                  _buildStandingsSection(),
                  const SizedBox(height: 48),
                  _buildNewsletterCard(),
                  const SizedBox(height: 48),
                  _buildSettingsSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB08D5B), width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?u=uforo'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uforo Ekong',
              style: GoogleFonts.notoSerif(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Poetry Enthusiast',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: Colors.white38,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewsletterCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF252D36).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE POET\'S CIRCLE',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB08D5B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Join our weekly gazette of verses and visual inspirations.',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.manrope(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Your Name',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.manrope(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitNewsletter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB08D5B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'SUBSCRIBE',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedPoemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY GALLERY',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB08D5B),
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'View All',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPoemCard(
                'Whispers in the Rain',
                'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?q=80&w=500&auto=format&fit=crop',
              ),
              _buildPoemCard(
                'Golden Hour Dreams',
                'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?q=80&w=500&auto=format&fit=crop',
              ),
              _buildPoemCard(
                'Starlit Pathways',
                'https://images.unsplash.com/photo-1532974297617-c0f05fe48bff?q=80&w=500&auto=format&fit=crop',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoemCard(String title, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSerif(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C4A59), Color(0xFF171B21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUPPORT THE CRAFT',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB08D5B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Help us keep the verses flowing. Your donations support the digital ink.',
            style: GoogleFonts.notoSerif(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<PaymentConfiguration>(
            future: _googlePayConfigFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                debugPrint('Google Pay Config Error: ${snapshot.error}');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration error:',
                      style: GoogleFonts.manrope(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.manrope(color: Colors.redAccent.withValues(alpha: 0.8), fontSize: 10),
                    ),
                  ],
                );
              }
              if (snapshot.hasData) {
                return GooglePayButton(
                  paymentConfiguration: snapshot.data!,
                  paymentItems: _paymentItems,
                  type: GooglePayButtonType.donate,
                  margin: const EdgeInsets.only(top: 15.0),
                  onPaymentResult: (result) {
                    debugPrint('Payment Result: $result');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your generous heart!'),
                        backgroundColor: Color(0xFFB08D5B),
                      ),
                    );
                  },
                  loadingIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Text(
                'Google Pay is not available on this device/platform.',
                style: GoogleFonts.manrope(color: Colors.white38, fontSize: 12),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsItem(Icons.history_rounded, 'Viewing History'),
        _buildSettingsItem(Icons.favorite_outline_rounded, 'Saved Verses'),
        _buildSettingsItem(Icons.brush_outlined, 'Appearance'),
        _buildSettingsItem(Icons.help_outline_rounded, 'Help & Support'),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white12,
          size: 14,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildStandingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREMIER LEAGUE STANDINGS',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB08D5B),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<TeamStanding>>(
          future: _standingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFFB08D5B)),
                ),
              );
            }
            if (snapshot.hasError) {
              return Text(
                'Failed to load standings.',
                style: GoogleFonts.manrope(color: Colors.redAccent.withValues(alpha: 0.8), fontSize: 14),
              );
            }
            
            final standings = snapshot.data;
            if (standings == null || standings.isEmpty) {
              return Text(
                'No standings data available.',
                style: GoogleFonts.manrope(color: Colors.white38, fontSize: 14),
              );
            }

            // Show top 10 teams
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF252D36).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: standings.length > 10 ? 10 : standings.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, index) {
                  final team = standings[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${team.rank}',
                            style: GoogleFonts.manrope(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Image.network(
                          team.badgeUrl,
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: Colors.white24, size: 32),
                        ),
                      ],
                    ),
                    title: Text(
                      team.teamName,
                      style: GoogleFonts.notoSerif(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'P: ${team.played} | W: ${team.win} | D: ${team.draw} | L: ${team.loss}',
                      style: GoogleFonts.manrope(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${team.points} pts',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFB08D5B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'GD: ${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}',
                          style: GoogleFonts.manrope(
                            color: team.goalDifference > 0 ? Colors.green[300] : (team.goalDifference < 0 ? Colors.red[300] : Colors.white54),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
