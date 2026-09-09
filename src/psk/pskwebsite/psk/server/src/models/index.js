/**
 * All Mongoose schemas for the demo platform.
 * Kept in one module so relationships stay easy to read.
 */
import mongoose from 'mongoose';

const { Schema, model } = mongoose;

/* ------------------------------------------------------------------ */
/* Sport / League / Event — the sportsbook offer                       */
/* ------------------------------------------------------------------ */
const sportSchema = new Schema({
  slug:      { type: String, required: true, unique: true, index: true },
  name:      { type: String, required: true },
  icon:      { type: String, default: '🏅' },
  marketSet: { type: String, enum: ['1x2', '12', 'outright'], default: '1x2' },
  order:     { type: Number, default: 0 }
}, { timestamps: true });

const leagueSchema = new Schema({
  slug:  { type: String, required: true, index: true },
  name:  { type: String, required: true },
  flag:  { type: String, default: '🏳️' },
  sport: { type: Schema.Types.ObjectId, ref: 'Sport', required: true, index: true }
}, { timestamps: true });
leagueSchema.index({ sport: 1, slug: 1 }, { unique: true });

const eventSchema = new Schema({
  code:        { type: Number, required: true, index: true },
  name:        { type: String, required: true },
  home:        { type: String },
  away:        { type: String },
  sport:       { type: Schema.Types.ObjectId, ref: 'Sport', required: true, index: true },
  league:      { type: Schema.Types.ObjectId, ref: 'League', required: true, index: true },
  startsAt:    { type: Date, required: true, index: true },
  live:        { type: Boolean, default: false, index: true },
  outright:    { type: Boolean, default: false },
  minute:      { type: Number, default: 0 },
  score:       { type: String, default: '' },
  /** market key -> decimal odds, e.g. { "1": 1.85, "X": 3.40, "2": 4.10 } */
  markets:     { type: Map, of: Number, default: {} },
  marketCount: { type: Number, default: 40 },
  status:      { type: String, enum: ['open', 'closed', 'settled'], default: 'open' },
  result:      { type: String, default: '' }
}, { timestamps: true });
eventSchema.index({ name: 'text' });

/* ------------------------------------------------------------------ */
/* Casino                                                              */
/* ------------------------------------------------------------------ */
const providerSchema = new Schema({
  slug: { type: String, required: true, unique: true },
  name: { type: String, required: true }
}, { timestamps: true });

const gameSchema = new Schema({
  slug:       { type: String, required: true, unique: true, index: true },
  title:      { type: String, required: true, index: true },
  provider:   { type: Schema.Types.ObjectId, ref: 'Provider', required: true, index: true },
  /** which client-side engine renders this game */
  engine:     { type: String, enum: ['slot','roulette','blackjack','crash','mines','dice','wheel','baccarat'], default: 'slot' },
  categories: { type: [String], default: [], index: true },
  /** presentation: emoji symbol + two hues used to paint the CSS thumbnail */
  symbol:     { type: String, default: '🎰' },
  hueA:       { type: Number, default: 210 },
  hueB:       { type: Number, default: 260 },
  rtp:        { type: Number, default: 96 },
  volatility: { type: String, enum: ['Niska','Srednja','Visoka'], default: 'Srednja' },
  lines:      { type: Number, default: 20 },
  minBet:     { type: Number, default: 0.1 },
  maxBet:     { type: Number, default: 50 },
  jackpot:    { type: Number, default: 0 },
  isLive:     { type: Boolean, default: false, index: true },
  players:    { type: Number, default: 0 },
  popularity: { type: Number, default: 0 }
}, { timestamps: true });
gameSchema.index({ title: 'text' });

/* ------------------------------------------------------------------ */
/* Users, tickets, casino rounds                                       */
/* ------------------------------------------------------------------ */
const userSchema = new Schema({
  username: { type: String, required: true, unique: true, trim: true, minlength: 3, maxlength: 24 },
  email:    { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String, required: true, select: false },
  balance:  { type: Number, default: 500 },      // demo credits, never real money
  role:     { type: String, enum: ['player', 'admin'], default: 'player' },
  limits:   {
    dailyDeposit: { type: Number, default: 0 },
    dailyLoss:    { type: Number, default: 0 },
    sessionMins:  { type: Number, default: 0 },
    selfExcludedUntil: { type: Date, default: null }
  },
  favourites: [{ type: Schema.Types.ObjectId, ref: 'Game' }]
}, { timestamps: true });

const selectionSchema = new Schema({
  event:      { type: Schema.Types.ObjectId, ref: 'Event' },
  eventName:  String,
  leagueName: String,
  marketKey:  String,
  marketLabel:String,
  odds:       Number,
  code:       Number,
  result:     { type: String, enum: ['open','won','lost','void'], default: 'open' }
}, { _id: false });

const ticketSchema = new Schema({
  ref:        { type: String, required: true, unique: true, index: true },
  user:       { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  selections: { type: [selectionSchema], validate: v => v.length > 0 },
  stake:      { type: Number, required: true, min: 0.5 },
  totalOdds:  { type: Number, required: true },
  potentialGross: Number,
  deduction:  Number,
  potentialNet:   Number,
  payout:     { type: Number, default: 0 },
  status:     { type: String, enum: ['open','won','lost','void'], default: 'open', index: true },
  shared:     { type: Boolean, default: false }
}, { timestamps: true });

const roundSchema = new Schema({
  user:   { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  game:   { type: Schema.Types.ObjectId, ref: 'Game', required: true },
  engine: String,
  bet:    Number,
  win:    Number,
  detail: { type: Schema.Types.Mixed, default: {} }
}, { timestamps: true });

/* ------------------------------------------------------------------ */
/* Content: promos, news, shops, lotteries, virtuals, forum            */
/* ------------------------------------------------------------------ */
const promoSchema = new Schema({
  slug: { type: String, required: true, unique: true },
  tag:  String, title: String, body: String, cta: String,
  hueA: Number, hueB: Number,
  terms: { type: Schema.Types.Mixed, default: {} },
  active: { type: Boolean, default: true }
}, { timestamps: true });

const newsSchema = new Schema({
  slug: { type: String, required: true, unique: true },
  category: String, title: String, excerpt: String, body: String,
  publishedAt: { type: Date, default: Date.now }
}, { timestamps: true });

const shopSchema = new Schema({
  city: String, address: String, hours: String, kind: String,
  lat: Number, lng: Number
}, { timestamps: true });

const lotterySchema = new Schema({
  slug: { type: String, required: true, unique: true },
  name: String, pick: Number, max: Number,
  drawInfo: String, jackpot: Number, price: Number
}, { timestamps: true });

const drawSchema = new Schema({
  lottery: { type: Schema.Types.ObjectId, ref: 'Lottery', index: true },
  round:   String,
  numbers: [Number],
  fund:    Number,
  drawnAt: { type: Date, default: Date.now }
}, { timestamps: true });

const virtualSchema = new Schema({
  slug: { type: String, required: true, unique: true },
  name: String, icon: String, symbol: String,
  hueA: Number, hueB: Number,
  intervalLabel: String, description: String, runners: Number
}, { timestamps: true });

const threadSchema = new Schema({
  slug: { type: String, required: true, unique: true },
  category: String,
  title: String,
  author: String,
  body: String,
  replies: [{
    author: String,
    body: String,
    createdAt: { type: Date, default: Date.now }
  }],
  views: { type: Number, default: 0 }
}, { timestamps: true });

/* ------------------------------------------------------------------ */
export const Sport    = model('Sport', sportSchema);
export const League   = model('League', leagueSchema);
export const Event    = model('Event', eventSchema);
export const Provider = model('Provider', providerSchema);
export const Game     = model('Game', gameSchema);
export const User     = model('User', userSchema);
export const Ticket   = model('Ticket', ticketSchema);
export const Round    = model('Round', roundSchema);
export const Promo    = model('Promo', promoSchema);
export const News     = model('News', newsSchema);
export const Shop     = model('Shop', shopSchema);
export const Lottery  = model('Lottery', lotterySchema);
export const Draw     = model('Draw', drawSchema);
export const Virtual  = model('Virtual', virtualSchema);
export const Thread   = model('Thread', threadSchema);
