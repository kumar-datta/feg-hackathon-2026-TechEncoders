import '../models/sport_event.dart';
import '../models/casino_game.dart';
import '../models/bet_slip_model.dart';

class MockPskData {
  static List<SportEvent> getSportsEvents() {
    return [
      // ==========================================
      // 1. LIVE MATCHES (IN-PLAY)
      // ==========================================

      // FOOTBALL - SUPERSPORT HNL
      const SportEvent(
        id: 'live_1',
        league: 'SuperSport HNL',
        leagueCountry: 'Croatia',
        sport: SportType.football,
        homeTeam: 'Dinamo Zagreb',
        awayTeam: 'Hajduk Split',
        startTime: 'Live',
        isLive: true,
        liveMinute: '67\'',
        homeScore: 2,
        awayScore: 1,
        hasBetBuilder: true,
        hasPskPrednost: true,
        hasFavoritPlus: true,
        mainOdds: [
          OddOption(id: 'live_1_1', label: '1', value: 1.35, previousValue: 1.40),
          OddOption(id: 'live_1_x', label: 'X', value: 4.80, previousValue: 4.50),
          OddOption(id: 'live_1_2', label: '2', value: 9.50, previousValue: 8.00),
        ],
        extraMarkets: [
          Market(
            name: 'Next Goal',
            options: [
              OddOption(id: 'live_1_g1', label: 'Dinamo', value: 1.85),
              OddOption(id: 'live_1_g0', label: 'No Goal', value: 2.60),
              OddOption(id: 'live_1_g2', label: 'Hajduk', value: 3.90),
            ],
          ),
          Market(
            name: 'Total Goals (3.5)',
            options: [
              OddOption(id: 'live_1_o35', label: 'Over 3.5', value: 1.95),
              OddOption(id: 'live_1_u35', label: 'Under 3.5', value: 1.75),
            ],
          ),
        ],
      ),

      // FOOTBALL - UEFA CHAMPIONS LEAGUE
      const SportEvent(
        id: 'live_2',
        league: 'UEFA Champions League',
        leagueCountry: 'Europe',
        sport: SportType.football,
        homeTeam: 'Real Madrid',
        awayTeam: 'Manchester City',
        startTime: 'Live',
        isLive: true,
        liveMinute: '41\'',
        homeScore: 1,
        awayScore: 1,
        hasBetBuilder: true,
        hasPskPrednost: true,
        mainOdds: [
          OddOption(id: 'live_2_1', label: '1', value: 2.70, previousValue: 2.60),
          OddOption(id: 'live_2_x', label: 'X', value: 3.10, previousValue: 3.20),
          OddOption(id: 'live_2_2', label: '2', value: 2.75, previousValue: 2.85),
        ],
        extraMarkets: [
          Market(
            name: 'Total Goals (2.5)',
            options: [
              OddOption(id: 'live_2_o25', label: 'Over 2.5', value: 1.60),
              OddOption(id: 'live_2_u25', label: 'Under 2.5', value: 2.20),
            ],
          ),
          Market(
            name: 'Both Teams to Score',
            options: [
              OddOption(id: 'live_2_gg_da', label: 'Yes', value: 1.45),
              OddOption(id: 'live_2_gg_ne', label: 'No', value: 2.55),
            ],
          ),
        ],
      ),

      // FOOTBALL - UEFA CHAMPIONS LEAGUE (2nd Match)
      const SportEvent(
        id: 'live_4',
        league: 'UEFA Champions League',
        leagueCountry: 'Europe',
        sport: SportType.football,
        homeTeam: 'Bayern Munich',
        awayTeam: 'Arsenal',
        startTime: 'Live',
        isLive: true,
        liveMinute: '54\'',
        homeScore: 1,
        awayScore: 0,
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'live_4_1', label: '1', value: 1.55, previousValue: 1.65),
          OddOption(id: 'live_4_x', label: 'X', value: 3.80, previousValue: 3.60),
          OddOption(id: 'live_4_2', label: '2', value: 6.00, previousValue: 5.50),
        ],
      ),

      // FOOTBALL - SERIE A
      const SportEvent(
        id: 'live_5',
        league: 'Serie A',
        leagueCountry: 'Italy',
        sport: SportType.football,
        homeTeam: 'Inter Milan',
        awayTeam: 'Juventus',
        startTime: 'Live',
        isLive: true,
        liveMinute: '23\'',
        homeScore: 0,
        awayScore: 0,
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'live_5_1', label: '1', value: 1.90),
          OddOption(id: 'live_5_x', label: 'X', value: 3.20),
          OddOption(id: 'live_5_2', label: '2', value: 4.10),
        ],
      ),

      // BASKETBALL - NBA LIVE
      const SportEvent(
        id: 'live_bball_1',
        league: 'NBA',
        leagueCountry: 'USA',
        sport: SportType.basketball,
        homeTeam: 'Denver Nuggets',
        awayTeam: 'Phoenix Suns',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'Q3 (08:24)',
        homeScore: 78,
        awayScore: 74,
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'live_bb_1', label: '1', value: 1.48, previousValue: 1.60),
          OddOption(id: 'live_bb_2', label: '2', value: 2.65, previousValue: 2.35),
        ],
        extraMarkets: [
          Market(
            name: 'Total Points (224.5)',
            options: [
              OddOption(id: 'live_bb_o224', label: 'Over 224.5', value: 1.90),
              OddOption(id: 'live_bb_u224', label: 'Under 224.5', value: 1.90),
            ],
          ),
        ],
      ),

      // TENNIS - ATP INDIAN WELLS LIVE
      const SportEvent(
        id: 'live_3',
        league: 'ATP Indian Wells',
        leagueCountry: 'USA',
        sport: SportType.tennis,
        homeTeam: 'Jannik Sinner',
        awayTeam: 'Carlos Alcaraz',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'Set 2 (4-3)',
        homeScore: 1,
        awayScore: 0,
        mainOdds: [
          OddOption(id: 'live_3_1', label: '1', value: 1.45, previousValue: 1.55),
          OddOption(id: 'live_3_2', label: '2', value: 2.65, previousValue: 2.40),
        ],
        extraMarkets: [
          Market(
            name: 'Total Games (22.5)',
            options: [
              OddOption(id: 'live_3_o22', label: 'Over 22.5', value: 1.80),
              OddOption(id: 'live_3_u22', label: 'Under 22.5', value: 1.95),
            ],
          ),
        ],
      ),

      // TENNIS - ATP DUBAI LIVE
      const SportEvent(
        id: 'live_ten_2',
        league: 'ATP Dubai',
        leagueCountry: 'UAE',
        sport: SportType.tennis,
        homeTeam: 'Novak Djokovic',
        awayTeam: 'Daniil Medvedev',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'Set 3 (2-1)',
        homeScore: 1,
        awayScore: 1,
        mainOdds: [
          OddOption(id: 'live_ten_2_1', label: '1', value: 1.62, previousValue: 1.70),
          OddOption(id: 'live_ten_2_2', label: '2', value: 2.25, previousValue: 2.10),
        ],
      ),

      // HOCKEY - NHL LIVE
      const SportEvent(
        id: 'live_hock_1',
        league: 'NHL',
        leagueCountry: 'USA / Canada',
        sport: SportType.hockey,
        homeTeam: 'New York Rangers',
        awayTeam: 'Boston Bruins',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'P2 (14:20)',
        homeScore: 2,
        awayScore: 1,
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'live_hk_1', label: '1', value: 1.75),
          OddOption(id: 'live_hk_x', label: 'X', value: 4.20),
          OddOption(id: 'live_hk_2', label: '2', value: 3.80),
        ],
      ),

      // HANDBALL - EHF CHAMPIONS LEAGUE LIVE
      const SportEvent(
        id: 'live_hand_1',
        league: 'EHF Champions League',
        leagueCountry: 'Europe',
        sport: SportType.handball,
        homeTeam: 'Telekom Veszprém',
        awayTeam: 'SC Magdeburg',
        startTime: 'Live',
        isLive: true,
        liveMinute: '38\'',
        homeScore: 19,
        awayScore: 18,
        mainOdds: [
          OddOption(id: 'live_hd_1', label: '1', value: 1.65),
          OddOption(id: 'live_hd_x', label: 'X', value: 8.00),
          OddOption(id: 'live_hd_2', label: '2', value: 2.45),
        ],
      ),

      // E-SPORTS - CS2 MAJOR LIVE
      const SportEvent(
        id: 'live_esp_1',
        league: 'CS2 PGL Major',
        leagueCountry: 'International',
        sport: SportType.esport,
        homeTeam: 'Natus Vincere (NAVI)',
        awayTeam: 'FaZe Clan',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'Map 2 (11-9)',
        homeScore: 1,
        awayScore: 0,
        mainOdds: [
          OddOption(id: 'live_es_1', label: '1', value: 1.38, previousValue: 1.50),
          OddOption(id: 'live_es_2', label: '2', value: 2.95, previousValue: 2.55),
        ],
      ),

      // VOLLEYBALL - CEV CHAMPIONS LEAGUE LIVE
      const SportEvent(
        id: 'live_vol_1',
        league: 'CEV Champions League',
        leagueCountry: 'Europe',
        sport: SportType.volleyball,
        homeTeam: 'Trentino Itas',
        awayTeam: 'Sir Sicoma Perugia',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'Set 3 (18-16)',
        homeScore: 1,
        awayScore: 1,
        mainOdds: [
          OddOption(id: 'live_vl_1', label: '1', value: 1.70),
          OddOption(id: 'live_vl_2', label: '2', value: 2.05),
        ],
      ),

      // DARTS - PDC PREMIER LEAGUE LIVE
      const SportEvent(
        id: 'live_dart_1',
        league: 'PDC Premier League',
        leagueCountry: 'United Kingdom',
        sport: SportType.darts,
        homeTeam: 'Luke Littler',
        awayTeam: 'Michael van Gerwen',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'Leg 7 (4-2)',
        homeScore: 1,
        awayScore: 0,
        mainOdds: [
          OddOption(id: 'live_dt_1', label: '1', value: 1.30, previousValue: 1.45),
          OddOption(id: 'live_dt_2', label: '2', value: 3.40, previousValue: 2.70),
        ],
      ),

      // WATER POLO - LEN CHAMPIONS LEAGUE LIVE
      const SportEvent(
        id: 'live_wp_1',
        league: 'LEN Champions League',
        leagueCountry: 'Europe',
        sport: SportType.waterPolo,
        homeTeam: 'VK Jug Dubrovnik',
        awayTeam: 'Pro Recco',
        startTime: 'Live',
        isLive: true,
        liveMinute: 'Q3 (03:15)',
        homeScore: 7,
        awayScore: 8,
        mainOdds: [
          OddOption(id: 'live_wp_1_1', label: '1', value: 3.10),
          OddOption(id: 'live_wp_1_x', label: 'X', value: 6.50),
          OddOption(id: 'live_wp_1_2', label: '2', value: 1.50),
        ],
      ),

      // ==========================================
      // 2. UPCOMING FOOTBALL
      // ==========================================

      // CROATIA - SUPERSPORT HNL (TODAY)
      const SportEvent(
        id: 'hnl_1',
        league: 'SuperSport HNL',
        leagueCountry: 'Croatia',
        sport: SportType.football,
        homeTeam: 'Rijeka',
        awayTeam: 'Osijek',
        startTime: 'Today 19:30 (in 2h)',
        hasBetBuilder: true,
        hasPskPrednost: true,
        hasFavoritPlus: true,
        mainOdds: [
          OddOption(id: 'hnl_1_1', label: '1', value: 1.80),
          OddOption(id: 'hnl_1_x', label: 'X', value: 3.50),
          OddOption(id: 'hnl_1_2', label: '2', value: 4.40),
        ],
        extraMarkets: [
          Market(
            name: 'Both Teams to Score',
            options: [
              OddOption(id: 'hnl_1_gg_da', label: 'Yes', value: 1.85),
              OddOption(id: 'hnl_1_gg_ne', label: 'No', value: 1.85),
            ],
          ),
          Market(
            name: 'Total Goals (2.5)',
            options: [
              OddOption(id: 'hnl_1_o25', label: 'Over 2.5', value: 1.90),
              OddOption(id: 'hnl_1_u25', label: 'Under 2.5', value: 1.85),
            ],
          ),
        ],
      ),

      // CROATIA - SUPERSPORT HNL (TOMORROW)
      const SportEvent(
        id: 'hnl_2',
        league: 'SuperSport HNL',
        leagueCountry: 'Croatia',
        sport: SportType.football,
        homeTeam: 'Lokomotiva Zagreb',
        awayTeam: 'HNK Gorica',
        startTime: 'Tomorrow 17:00',
        hasBetBuilder: true,
        hasPskPrednost: true,
        mainOdds: [
          OddOption(id: 'hnl_2_1', label: '1', value: 1.95),
          OddOption(id: 'hnl_2_x', label: 'X', value: 3.40),
          OddOption(id: 'hnl_2_2', label: '2', value: 3.80),
        ],
      ),

      // CROATIA - SUPERSPORT HNL (WEEKEND SATURDAY)
      const SportEvent(
        id: 'hnl_3',
        league: 'SuperSport HNL',
        leagueCountry: 'Croatia',
        sport: SportType.football,
        homeTeam: 'Slaven Belupo',
        awayTeam: 'Istra 1961',
        startTime: 'Weekend Saturday 15:00',
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'hnl_3_1', label: '1', value: 2.20),
          OddOption(id: 'hnl_3_x', label: 'X', value: 3.10),
          OddOption(id: 'hnl_3_2', label: '2', value: 3.30),
        ],
      ),

      // CROATIA - SUPERSPORT HNL (WEEKEND SUNDAY)
      const SportEvent(
        id: 'hnl_4',
        league: 'SuperSport HNL',
        leagueCountry: 'Croatia',
        sport: SportType.football,
        homeTeam: 'Varaždin',
        awayTeam: 'Šibenik',
        startTime: 'Weekend Sunday 17:30',
        hasBetBuilder: true,
        hasPskPrednost: true,
        mainOdds: [
          OddOption(id: 'hnl_4_1', label: '1', value: 1.70),
          OddOption(id: 'hnl_4_x', label: 'X', value: 3.60),
          OddOption(id: 'hnl_4_2', label: '2', value: 4.80),
        ],
      ),

      // PREMIER LEAGUE (TODAY)
      const SportEvent(
        id: 'epl_1',
        league: 'Premier League',
        leagueCountry: 'England',
        sport: SportType.football,
        homeTeam: 'Liverpool',
        awayTeam: 'Chelsea',
        startTime: 'Today 21:00 (in 3h)',
        hasBetBuilder: true,
        hasPskPrednost: true,
        hasFavoritPlus: true,
        mainOdds: [
          OddOption(id: 'epl_1_1', label: '1', value: 1.65),
          OddOption(id: 'epl_1_x', label: 'X', value: 4.10),
          OddOption(id: 'epl_1_2', label: '2', value: 5.00),
        ],
        extraMarkets: [
          Market(
            name: 'Total Goals (2.5)',
            options: [
              OddOption(id: 'epl_1_o25', label: 'Over 2.5', value: 1.55),
              OddOption(id: 'epl_1_u25', label: 'Under 2.5', value: 2.35),
            ],
          ),
          Market(
            name: 'Both Teams to Score',
            options: [
              OddOption(id: 'epl_1_gg_da', label: 'Yes', value: 1.60),
              OddOption(id: 'epl_1_gg_ne', label: 'No', value: 2.25),
            ],
          ),
        ],
      ),

      // PREMIER LEAGUE (TOMORROW)
      const SportEvent(
        id: 'epl_2',
        league: 'Premier League',
        leagueCountry: 'England',
        sport: SportType.football,
        homeTeam: 'Arsenal',
        awayTeam: 'Tottenham Hotspur',
        startTime: 'Tomorrow 17:30',
        hasBetBuilder: true,
        hasPskPrednost: true,
        mainOdds: [
          OddOption(id: 'epl_2_1', label: '1', value: 1.70),
          OddOption(id: 'epl_2_x', label: 'X', value: 3.90),
          OddOption(id: 'epl_2_2', label: '2', value: 4.60),
        ],
      ),

      // PREMIER LEAGUE (WEEKEND)
      const SportEvent(
        id: 'epl_3',
        league: 'Premier League',
        leagueCountry: 'England',
        sport: SportType.football,
        homeTeam: 'Manchester City',
        awayTeam: 'Aston Villa',
        startTime: 'Weekend Saturday 13:30',
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'epl_3_1', label: '1', value: 1.30),
          OddOption(id: 'epl_3_x', label: 'X', value: 5.60),
          OddOption(id: 'epl_3_2', label: '2', value: 8.50),
        ],
      ),

      // LA LIGA (WEEKEND EL CLASICO)
      const SportEvent(
        id: 'clasico_1',
        league: 'La Liga',
        leagueCountry: 'Spain',
        sport: SportType.football,
        homeTeam: 'Real Madrid',
        awayTeam: 'Barcelona',
        startTime: 'Weekend Sunday 21:00',
        hasBetBuilder: true,
        hasPskPrednost: true,
        hasFavoritPlus: true,
        mainOdds: [
          OddOption(id: 'cla_1', label: '1', value: 2.15),
          OddOption(id: 'cla_x', label: 'X', value: 3.65),
          OddOption(id: 'cla_2', label: '2', value: 3.10),
        ],
        extraMarkets: [
          Market(
            name: 'Total Goals (3.5)',
            options: [
              OddOption(id: 'cla_o35', label: 'Over 3.5', value: 2.20),
              OddOption(id: 'cla_u35', label: 'Under 3.5', value: 1.65),
            ],
          ),
        ],
      ),

      // ==========================================
      // 3. BASKETBALL
      // ==========================================

      const SportEvent(
        id: 'nba_1',
        league: 'NBA',
        leagueCountry: 'USA',
        sport: SportType.basketball,
        homeTeam: 'Los Angeles Lakers',
        awayTeam: 'Golden State Warriors',
        startTime: 'Tonight 04:30',
        hasBetBuilder: true,
        hasPskPrednost: true,
        mainOdds: [
          OddOption(id: 'nba_1_1', label: '1', value: 1.75),
          OddOption(id: 'nba_1_2', label: '2', value: 2.10),
        ],
      ),

      const SportEvent(
        id: 'nba_2',
        league: 'NBA',
        leagueCountry: 'USA',
        sport: SportType.basketball,
        homeTeam: 'Boston Celtics',
        awayTeam: 'Dallas Mavericks',
        startTime: 'Tonight 02:00',
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'nba_2_1', label: '1', value: 1.40),
          OddOption(id: 'nba_2_2', label: '2', value: 2.90),
        ],
      ),

      const SportEvent(
        id: 'euro_1',
        league: 'EuroLeague',
        leagueCountry: 'Europe',
        sport: SportType.basketball,
        homeTeam: 'Real Madrid Baloncesto',
        awayTeam: 'Panathinaikos',
        startTime: 'Today 20:45 (in 3h)',
        hasBetBuilder: true,
        hasFavoritPlus: true,
        mainOdds: [
          OddOption(id: 'euro_1_1', label: '1', value: 1.55),
          OddOption(id: 'euro_1_2', label: '2', value: 2.45),
        ],
      ),

      const SportEvent(
        id: 'cro_bball_1',
        league: 'Premijer Liga',
        leagueCountry: 'Croatia',
        sport: SportType.basketball,
        homeTeam: 'KK Split',
        awayTeam: 'KK Zadar',
        startTime: 'Tomorrow 18:00',
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'cro_bb_1', label: '1', value: 1.85),
          OddOption(id: 'cro_bb_2', label: '2', value: 1.95),
        ],
      ),

      // ==========================================
      // 4. TENNIS
      // ==========================================

      const SportEvent(
        id: 'ten_1',
        league: 'WTA Finals',
        leagueCountry: 'International',
        sport: SportType.tennis,
        homeTeam: 'Iga Swiatek',
        awayTeam: 'Aryna Sabalenka',
        startTime: 'Today 19:00 (in 2h)',
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'ten_1_1', label: '1', value: 1.68),
          OddOption(id: 'ten_1_2', label: '2', value: 2.18),
        ],
      ),

      const SportEvent(
        id: 'ten_2',
        league: 'WTA Miami Open',
        leagueCountry: 'USA',
        sport: SportType.tennis,
        homeTeam: 'Donna Vekić',
        awayTeam: 'Coco Gauff',
        startTime: 'Tomorrow 16:30',
        mainOdds: [
          OddOption(id: 'ten_2_1', label: '1', value: 2.85),
          OddOption(id: 'ten_2_2', label: '2', value: 1.42),
        ],
      ),

      const SportEvent(
        id: 'ten_3',
        league: 'ATP Monte Carlo',
        leagueCountry: 'Monaco',
        sport: SportType.tennis,
        homeTeam: 'Alexander Zverev',
        awayTeam: 'Stefanos Tsitsipas',
        startTime: 'Weekend Saturday 14:00',
        mainOdds: [
          OddOption(id: 'ten_3_1', label: '1', value: 1.90),
          OddOption(id: 'ten_3_2', label: '2', value: 1.90),
        ],
      ),

      // ==========================================
      // 5. HOCKEY
      // ==========================================

      const SportEvent(
        id: 'hock_1',
        league: 'NHL',
        leagueCountry: 'USA / Canada',
        sport: SportType.hockey,
        homeTeam: 'Colorado Avalanche',
        awayTeam: 'Edmonton Oilers',
        startTime: 'Tonight 03:00',
        hasBetBuilder: true,
        mainOdds: [
          OddOption(id: 'hk_1_1', label: '1', value: 2.10),
          OddOption(id: 'hk_1_x', label: 'X', value: 4.20),
          OddOption(id: 'hk_1_2', label: '2', value: 2.80),
        ],
      ),

      const SportEvent(
        id: 'hock_2',
        league: 'ICE Hockey League',
        leagueCountry: 'Austria / Croatia',
        sport: SportType.hockey,
        homeTeam: 'Medveščak Zagreb',
        awayTeam: 'Red Bull Salzburg',
        startTime: 'Tomorrow 19:15',
        mainOdds: [
          OddOption(id: 'hk_2_1', label: '1', value: 3.40),
          OddOption(id: 'hk_2_x', label: 'X', value: 4.50),
          OddOption(id: 'hk_2_2', label: '2', value: 1.70),
        ],
      ),

      // ==========================================
      // 6. HANDBALL
      // ==========================================

      const SportEvent(
        id: 'handball_1',
        league: 'EHF Champions League',
        leagueCountry: 'Europe',
        sport: SportType.handball,
        homeTeam: 'PPD Zagreb',
        awayTeam: 'Paris Saint-Germain',
        startTime: 'Today 18:45 (in 1h)',
        hasFavoritPlus: true,
        mainOdds: [
          OddOption(id: 'handball_1_1', label: '1', value: 3.20),
          OddOption(id: 'handball_1_x', label: 'X', value: 8.50),
          OddOption(id: 'handball_1_2', label: '2', value: 1.45),
        ],
      ),

      const SportEvent(
        id: 'handball_2',
        league: 'EHF European League',
        leagueCountry: 'Europe',
        sport: SportType.handball,
        homeTeam: 'RK Nexe Našice',
        awayTeam: 'Füchse Berlin',
        startTime: 'Tomorrow 20:45',
        mainOdds: [
          OddOption(id: 'handball_2_1', label: '1', value: 2.70),
          OddOption(id: 'handball_2_x', label: 'X', value: 8.00),
          OddOption(id: 'handball_2_2', label: '2', value: 1.60),
        ],
      ),

      // ==========================================
      // 7. E-SPORTS
      // ==========================================

      const SportEvent(
        id: 'esp_1',
        league: 'CS2 ESL Pro League',
        leagueCountry: 'International',
        sport: SportType.esport,
        homeTeam: 'Team Vitality',
        awayTeam: 'G2 Esports',
        startTime: 'Today 19:00 (in 2h)',
        mainOdds: [
          OddOption(id: 'esp_1_1', label: '1', value: 1.65),
          OddOption(id: 'esp_1_2', label: '2', value: 2.20),
        ],
      ),

      const SportEvent(
        id: 'esp_2',
        league: 'League of Legends LCK',
        leagueCountry: 'South Korea',
        sport: SportType.esport,
        homeTeam: 'T1',
        awayTeam: 'Gen.G',
        startTime: 'Tomorrow 11:00',
        mainOdds: [
          OddOption(id: 'esp_2_1', label: '1', value: 1.85),
          OddOption(id: 'esp_2_2', label: '2', value: 1.95),
        ],
      ),

      // ==========================================
      // 8. VOLLEYBALL
      // ==========================================

      const SportEvent(
        id: 'vol_1',
        league: 'CEV Cup',
        leagueCountry: 'Europe',
        sport: SportType.volleyball,
        homeTeam: 'HAOK Mladost Zagreb',
        awayTeam: 'Lube Civitanova',
        startTime: 'Tomorrow 18:00',
        mainOdds: [
          OddOption(id: 'vol_1_1', label: '1', value: 4.10),
          OddOption(id: 'vol_1_2', label: '2', value: 1.22),
        ],
      ),

      const SportEvent(
        id: 'vol_2',
        league: 'SuperLega',
        leagueCountry: 'Italy',
        sport: SportType.volleyball,
        homeTeam: 'Vero Volley Monza',
        awayTeam: 'Modena Volley',
        startTime: 'Weekend Sunday 18:00',
        mainOdds: [
          OddOption(id: 'vol_2_1', label: '1', value: 1.60),
          OddOption(id: 'vol_2_2', label: '2', value: 2.25),
        ],
      ),

      // ==========================================
      // 9. DARTS
      // ==========================================

      const SportEvent(
        id: 'dart_1',
        league: 'PDC World Series',
        leagueCountry: 'United Kingdom',
        sport: SportType.darts,
        homeTeam: 'Gerwyn Price',
        awayTeam: 'Michael Smith',
        startTime: 'Today 21:15 (in 3h)',
        mainOdds: [
          OddOption(id: 'dt_1_1', label: '1', value: 1.75),
          OddOption(id: 'dt_1_2', label: '2', value: 2.05),
        ],
      ),

      const SportEvent(
        id: 'dart_2',
        league: 'PDC World Series',
        leagueCountry: 'United Kingdom',
        sport: SportType.darts,
        homeTeam: 'Rob Cross',
        awayTeam: 'Nathan Aspinall',
        startTime: 'Tomorrow 20:00',
        mainOdds: [
          OddOption(id: 'dt_2_1', label: '1', value: 1.85),
          OddOption(id: 'dt_2_2', label: '2', value: 1.95),
        ],
      ),

      // ==========================================
      // 10. WATER POLO
      // ==========================================

      const SportEvent(
        id: 'wp_1',
        league: 'LEN Champions League',
        leagueCountry: 'Europe',
        sport: SportType.waterPolo,
        homeTeam: 'Jadran Split',
        awayTeam: 'Ferencváros',
        startTime: 'Tomorrow 20:00',
        mainOdds: [
          OddOption(id: 'wp_1_1', label: '1', value: 2.40),
          OddOption(id: 'wp_1_x', label: 'X', value: 6.20),
          OddOption(id: 'wp_1_2', label: '2', value: 1.75),
        ],
      ),

      const SportEvent(
        id: 'wp_2',
        league: 'Croatian Water Polo Championship',
        leagueCountry: 'Croatia',
        sport: SportType.waterPolo,
        homeTeam: 'Mladost Zagreb',
        awayTeam: 'Solaris Šibenik',
        startTime: 'Weekend Saturday 18:30',
        mainOdds: [
          OddOption(id: 'wp_2_1', label: '1', value: 1.25),
          OddOption(id: 'wp_2_x', label: 'X', value: 8.00),
          OddOption(id: 'wp_2_2', label: '2', value: 4.80),
        ],
      ),
    ];
  }

  // ==========================================
  // CASINO GAMES (ALL CATEGORIES & PROVIDERS)
  // ==========================================
  static List<CasinoGame> getCasinoGames() {
    return [
      // POPULAR & EXCLUSIVE
      const CasinoGame(
        id: 'vatreni_cup',
        title: 'Vatreni Cup',
        provider: 'Playtech',
        category: CasinoCategory.popular,
        imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
        isExclusive: true,
        hasJackpot: true,
        jackpotAmount: 184520.40,
        badge: 'EXCLUSIVE',
      ),
      const CasinoGame(
        id: 'psk_hot_40',
        title: 'PSK HOT 40',
        provider: 'Fazi',
        category: CasinoCategory.popular,
        imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80',
        isExclusive: true,
        hasJackpot: true,
        jackpotAmount: 54310.15,
        badge: 'PSK BRAND',
      ),
      const CasinoGame(
        id: 'gates_of_olympus',
        title: 'Gates of Olympus 1000',
        provider: 'Pragmatic Play',
        category: CasinoCategory.popular,
        imageUrl: 'https://images.unsplash.com/photo-1579208575657-c595a05383b7?w=400&q=80',
        badge: 'TOP GAME',
      ),
      const CasinoGame(
        id: 'sweet_bonanza',
        title: 'Sweet Bonanza',
        provider: 'Pragmatic Play',
        category: CasinoCategory.popular,
        imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400&q=80',
        badge: 'MULTIPLIER',
      ),
      const CasinoGame(
        id: 'big_bass_bonanza',
        title: 'Big Bass Bonanza',
        provider: 'Pragmatic Play',
        category: CasinoCategory.popular,
        imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80',
        badge: 'POPULAR',
      ),

      // NEW GAMES
      const CasinoGame(
        id: 'forge_of_olympus',
        title: 'Forge of Olympus',
        provider: 'Pragmatic Play',
        category: CasinoCategory.newGames,
        imageUrl: 'https://images.unsplash.com/photo-1579208575657-c595a05383b7?w=400&q=80',
        isNew: true,
        badge: 'NEW',
      ),
      const CasinoGame(
        id: 'fire_stampede',
        title: 'Fire Stampede',
        provider: 'Pragmatic Play',
        category: CasinoCategory.newGames,
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
        isNew: true,
        hasJackpot: true,
        jackpotAmount: 48900.00,
        badge: 'NEW JACKPOT',
      ),
      const CasinoGame(
        id: 'wild_west_duels',
        title: 'Wild West Duels',
        provider: 'Pragmatic Play',
        category: CasinoCategory.newGames,
        imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=400&q=80',
        isNew: true,
        badge: 'NEW',
      ),
      const CasinoGame(
        id: 'buffalo_blitz_live',
        title: 'Buffalo Blitz Live Slots',
        provider: 'Playtech',
        category: CasinoCategory.newGames,
        imageUrl: 'https://images.unsplash.com/photo-1511193311914-0346f16efe90?w=400&q=80',
        isNew: true,
        isExclusive: true,
        badge: 'NEW LIVE',
      ),

      // JACKPOT GAMES
      const CasinoGame(
        id: 'shining_crown',
        title: 'Shining Crown',
        provider: 'EGT Digital',
        category: CasinoCategory.jackpot,
        imageUrl: 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?w=400&q=80',
        hasJackpot: true,
        jackpotAmount: 342910.88,
        badge: 'MEGA JACKPOT',
      ),
      const CasinoGame(
        id: 'burning_hot',
        title: '40 Burning Hot',
        provider: 'EGT Digital',
        category: CasinoCategory.jackpot,
        imageUrl: 'https://images.unsplash.com/photo-1511193311914-0346f16efe90?w=400&q=80',
        hasJackpot: true,
        jackpotAmount: 89340.00,
        badge: 'JACKPOT',
      ),
      const CasinoGame(
        id: 'age_of_gods',
        title: 'Age of the Gods: Storms',
        provider: 'Playtech',
        category: CasinoCategory.jackpot,
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80',
        hasJackpot: true,
        jackpotAmount: 145020.10,
        badge: 'PROGRESSIVE',
      ),
      const CasinoGame(
        id: 'super_hot_20',
        title: '20 Super Hot',
        provider: 'EGT Digital',
        category: CasinoCategory.jackpot,
        imageUrl: 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?w=400&q=80',
        hasJackpot: true,
        jackpotAmount: 62150.30,
        badge: 'JACKPOT',
      ),
      const CasinoGame(
        id: 'diamond_plus',
        title: 'Diamond Plus',
        provider: 'EGT Digital',
        category: CasinoCategory.jackpot,
        imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80',
        hasJackpot: true,
        jackpotAmount: 118400.00,
        badge: 'JACKPOT',
      ),

      // SLOTS (CLASSIC & VIDEO)
      const CasinoGame(
        id: 'book_of_ra',
        title: 'Book of Ra Deluxe',
        provider: 'Novomatic',
        category: CasinoCategory.slots,
        imageUrl: 'https://images.unsplash.com/photo-1605870445919-838d190e8e1b?w=400&q=80',
        badge: 'CLASSIC',
      ),
      const CasinoGame(
        id: 'lucky_ladys_charm',
        title: 'Lucky Lady\'s Charm',
        provider: 'Novomatic',
        category: CasinoCategory.slots,
        imageUrl: 'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=400&q=80',
        badge: 'RETRO',
      ),
      const CasinoGame(
        id: 'sizzling_hot',
        title: 'Sizzling Hot Deluxe',
        provider: 'Novomatic',
        category: CasinoCategory.slots,
        imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80',
        badge: 'HOT 7s',
      ),
      const CasinoGame(
        id: 'sugar_rush',
        title: 'Sugar Rush 1000',
        provider: 'Pragmatic Play',
        category: CasinoCategory.slots,
        imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400&q=80',
        badge: 'CLUSTER PAYS',
      ),
      const CasinoGame(
        id: 'dolphins_pearl',
        title: 'Dolphin\'s Pearl Deluxe',
        provider: 'Novomatic',
        category: CasinoCategory.slots,
        imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80',
      ),

      // TABLE GAMES & LIVE CASINO
      const CasinoGame(
        id: 'european_roulette',
        title: 'European Roulette Pro',
        provider: 'Playtech',
        category: CasinoCategory.tableGames,
        imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80',
        badge: 'LIVE TABLE',
      ),
      const CasinoGame(
        id: 'blackjack_vip',
        title: 'PSK VIP Blackjack',
        provider: 'Playtech',
        category: CasinoCategory.tableGames,
        imageUrl: 'https://images.unsplash.com/photo-1511193311914-0346f16efe90?w=400&q=80',
        isExclusive: true,
        badge: 'VIP CLUB',
      ),
      const CasinoGame(
        id: 'quantum_roulette',
        title: 'Quantum Roulette Live',
        provider: 'Playtech',
        category: CasinoCategory.tableGames,
        imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80',
        badge: '500x MULTI',
      ),
      const CasinoGame(
        id: 'classic_baccarat',
        title: 'Classic Baccarat',
        provider: 'Playtech',
        category: CasinoCategory.tableGames,
        imageUrl: 'https://images.unsplash.com/photo-1511193311914-0346f16efe90?w=400&q=80',
      ),

      // MEGAWAYS
      const CasinoGame(
        id: 'madame_destiny_mw',
        title: 'Madame Destiny Megaways',
        provider: 'Pragmatic Play',
        category: CasinoCategory.megaways,
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80',
        badge: '200,704 WAYS',
      ),
      const CasinoGame(
        id: 'great_rhino_mw',
        title: 'Great Rhino Megaways',
        provider: 'Pragmatic Play',
        category: CasinoCategory.megaways,
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
        badge: 'MEGAWAYS',
      ),
      const CasinoGame(
        id: 'dog_house_mw',
        title: 'The Dog House Megaways',
        provider: 'Pragmatic Play',
        category: CasinoCategory.megaways,
        imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400&q=80',
        badge: 'STICKY WILDS',
      ),
    ];
  }

  // ==========================================
  // PSK ARENA & FORUM COMMUNITY TICKETS
  // ==========================================
  static List<Map<String, dynamic>> getArenaTickets() {
    return [
      {
        'user': 'Ivan_Master99',
        'avatar': '🏆',
        'title': 'Champions League + SuperSport HNL Combo',
        'stake': 10.0,
        'odds': 18.75,
        'potentialWin': 178.13,
        'likes': 142,
        'copiedCount': 89,
        'selections': [
          const BetSelection(
            eventId: 'live_1',
            homeTeam: 'Dinamo Zagreb',
            awayTeam: 'Hajduk Split',
            league: 'SuperSport HNL',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.85,
          ),
          const BetSelection(
            eventId: 'live_2',
            homeTeam: 'Real Madrid',
            awayTeam: 'Manchester City',
            league: 'Champions League',
            marketName: 'Both Teams to Score',
            selectionLabel: 'Yes',
            oddValue: 1.65,
          ),
          const BetSelection(
            eventId: 'epl_1',
            homeTeam: 'Liverpool',
            awayTeam: 'Chelsea',
            league: 'Premier League',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.65,
          ),
          const BetSelection(
            eventId: 'hnl_1',
            homeTeam: 'Rijeka',
            awayTeam: 'Osijek',
            league: 'SuperSport HNL',
            marketName: 'Total Goals',
            selectionLabel: 'Over 2.5',
            oddValue: 1.90,
          ),
        ],
      },
      {
        'user': 'Pro_Bettor_99',
        'avatar': '⭐',
        'title': 'NBA Night Game Special',
        'stake': 20.0,
        'odds': 6.84,
        'potentialWin': 129.96,
        'likes': 98,
        'copiedCount': 45,
        'selections': [
          const BetSelection(
            eventId: 'nba_1',
            homeTeam: 'LA Lakers',
            awayTeam: 'Golden State',
            league: 'NBA',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.80,
          ),
          const BetSelection(
            eventId: 'nba_2',
            homeTeam: 'Boston Celtics',
            awayTeam: 'Dallas Mavericks',
            league: 'NBA',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.45,
          ),
          const BetSelection(
            eventId: 'live_3',
            homeTeam: 'Jannik Sinner',
            awayTeam: 'Carlos Alcaraz',
            league: 'ATP',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.62,
          ),
        ],
      },
      {
        'user': 'Zagreb_Punter',
        'avatar': '🇭🇷',
        'title': 'Croatian SuperSport HNL Weekend 4-Fold',
        'stake': 15.0,
        'odds': 12.40,
        'potentialWin': 176.70,
        'likes': 76,
        'copiedCount': 52,
        'selections': [
          const BetSelection(
            eventId: 'hnl_1',
            homeTeam: 'Rijeka',
            awayTeam: 'Osijek',
            league: 'SuperSport HNL',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.80,
          ),
          const BetSelection(
            eventId: 'hnl_2',
            homeTeam: 'Lokomotiva',
            awayTeam: 'Gorica',
            league: 'SuperSport HNL',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.95,
          ),
          const BetSelection(
            eventId: 'hnl_4',
            homeTeam: 'Varaždin',
            awayTeam: 'Šibenik',
            league: 'SuperSport HNL',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.70,
          ),
        ],
      },
      {
        'user': 'EuroAccaKing',
        'avatar': '🔥',
        'title': 'Both Teams to Score (BTTS) Europe Special',
        'stake': 25.0,
        'odds': 8.95,
        'potentialWin': 212.56,
        'likes': 114,
        'copiedCount': 68,
        'selections': [
          const BetSelection(
            eventId: 'epl_1',
            homeTeam: 'Liverpool',
            awayTeam: 'Chelsea',
            league: 'Premier League',
            marketName: 'Both Teams to Score',
            selectionLabel: 'Yes',
            oddValue: 1.60,
          ),
          const BetSelection(
            eventId: 'live_2',
            homeTeam: 'Real Madrid',
            awayTeam: 'Manchester City',
            league: 'Champions League',
            marketName: 'Both Teams to Score',
            selectionLabel: 'Yes',
            oddValue: 1.45,
          ),
          const BetSelection(
            eventId: 'clasico_1',
            homeTeam: 'Real Madrid',
            awayTeam: 'Barcelona',
            league: 'La Liga',
            marketName: 'Both Teams to Score',
            selectionLabel: 'Yes',
            oddValue: 1.55,
          ),
        ],
      },
      {
        'user': 'TennisSniper',
        'avatar': '🎾',
        'title': 'Grand Slam & Masters Multi-Match',
        'stake': 30.0,
        'odds': 4.60,
        'potentialWin': 131.10,
        'likes': 63,
        'copiedCount': 31,
        'selections': [
          const BetSelection(
            eventId: 'live_3',
            homeTeam: 'Jannik Sinner',
            awayTeam: 'Carlos Alcaraz',
            league: 'ATP Indian Wells',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.45,
          ),
          const BetSelection(
            eventId: 'ten_1',
            homeTeam: 'Iga Swiatek',
            awayTeam: 'Aryna Sabalenka',
            league: 'WTA Finals',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.68,
          ),
          const BetSelection(
            eventId: 'live_ten_2',
            homeTeam: 'Novak Djokovic',
            awayTeam: 'Daniil Medvedev',
            league: 'ATP Dubai',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.62,
          ),
        ],
      },
      {
        'user': 'SafePlay_Daily',
        'avatar': '🛡️',
        'title': 'Low-Risk 1.30 - 1.55 Daily Banker',
        'stake': 50.0,
        'odds': 2.15,
        'potentialWin': 102.13,
        'likes': 208,
        'copiedCount': 173,
        'selections': [
          const BetSelection(
            eventId: 'epl_3',
            homeTeam: 'Manchester City',
            awayTeam: 'Aston Villa',
            league: 'Premier League',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.30,
          ),
          const BetSelection(
            eventId: 'nba_2',
            homeTeam: 'Boston Celtics',
            awayTeam: 'Dallas Mavericks',
            league: 'NBA',
            marketName: 'Match Winner',
            selectionLabel: '1',
            oddValue: 1.40,
          ),
        ],
      },
    ];
  }
}
