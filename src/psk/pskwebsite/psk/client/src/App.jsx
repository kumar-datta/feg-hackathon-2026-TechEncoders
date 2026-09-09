import { Routes, Route } from 'react-router-dom';

import Header from './components/Header';
import Footer from './components/Footer';
import ToastHost from './components/ToastHost';
import ModalHost from './components/ModalHost';
import ScrollToTop from './components/ScrollToTop';
import AssistantWidget from './components/AssistantWidget';

import Home from './pages/Home';
import Sportsbook from './pages/Sportsbook';
import Casino from './pages/Casino';
import LiveCasino from './pages/LiveCasino';
import Providers from './pages/Providers';
import Loto from './pages/Loto';
import Virtuals from './pages/Virtuals';
import Promotions from './pages/Promotions';
import Arena from './pages/Arena';
import SwipeAndBet from './pages/SwipeAndBet';
import Forum from './pages/Forum';
import ThreadPage from './pages/ThreadPage';
import Results from './pages/Results';
import Statistics from './pages/Statistics';
import News from './pages/News';
import ArticlePage from './pages/ArticlePage';
import Shops from './pages/Shops';
import MobileApp from './pages/MobileApp';
import Search from './pages/Search';
import Login from './pages/Login';
import Register from './pages/Register';
import Account from './pages/Account';
import Tickets from './pages/Tickets';
import Checkout from './pages/Checkout';
import Help from './pages/Help';
import About from './pages/About';
import Rules from './pages/Rules';
import Responsible from './pages/Responsible';
import Privacy from './pages/Privacy';
import Contact from './pages/Contact';
import ChampionsClub from './pages/ChampionsClub';
import NotFound from './pages/NotFound';

export default function App() {
  return (
    <>
      <ScrollToTop />
      <Header />

      <main>
        <Routes>
          <Route path="/" element={<Home />} />

          {/* sportsbook */}
          <Route path="/oklade" element={<Sportsbook />} />
          <Route path="/oklade/:sport" element={<Sportsbook />} />

          {/* casino */}
          <Route path="/casino" element={<Casino />} />
          <Route path="/live-casino" element={<LiveCasino />} />
          <Route path="/provideri" element={<Providers />} />

          {/* other products */}
          <Route path="/loto" element={<Loto />} />
          <Route path="/virtualne-igre" element={<Virtuals />} />
          <Route path="/swipe-and-bet" element={<SwipeAndBet />} />
          <Route path="/arena" element={<Arena />} />
          <Route path="/promocije" element={<Promotions />} />

          {/* community & info */}
          <Route path="/forum" element={<Forum />} />
          <Route path="/forum/:slug" element={<ThreadPage />} />
          <Route path="/rezultati" element={<Results />} />
          <Route path="/statistika" element={<Statistics />} />
          <Route path="/novosti" element={<News />} />
          <Route path="/novosti/:slug" element={<ArticlePage />} />
          <Route path="/poslovnice" element={<Shops />} />
          <Route path="/mobilna-aplikacija" element={<MobileApp />} />
          <Route path="/klub-prvaka" element={<ChampionsClub />} />
          <Route path="/pretraga" element={<Search />} />

          {/* account */}
          <Route path="/prijava" element={<Login />} />
          <Route path="/registracija" element={<Register />} />
          <Route path="/racun" element={<Account />} />
          <Route path="/listici" element={<Tickets />} />
          <Route path="/checkout" element={<Checkout />} />

          {/* legal & support */}
          <Route path="/pomoc" element={<Help />} />
          <Route path="/o-nama" element={<About />} />
          <Route path="/pravila-igre" element={<Rules />} />
          <Route path="/odgovorno-igranje" element={<Responsible />} />
          <Route path="/pravila-privatnosti" element={<Privacy />} />
          <Route path="/kontakt" element={<Contact />} />

          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>

      <Footer />
      <ToastHost />
      <ModalHost />
      <AssistantWidget />
    </>
  );
}
