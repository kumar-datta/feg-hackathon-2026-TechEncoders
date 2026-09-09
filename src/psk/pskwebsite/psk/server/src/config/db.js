import mongoose from 'mongoose';

/**
 * Connect to MongoDB. The URI comes from MONGODB_URI and falls back to a
 * local instance so the project runs with no configuration on a dev machine.
 */
export async function connectDB() {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/psk_demo';
  mongoose.set('strictQuery', true);

  try {
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 8000 });
    const { host, name } = mongoose.connection;
    console.log(`[db] connected to ${host}/${name}`);
  } catch (err) {
    console.error('[db] connection failed:', err.message);
    console.error('[db] Is MongoDB running? Start it locally or set MONGODB_URI to an Atlas cluster.');
    throw err;
  }

  mongoose.connection.on('disconnected', () => console.warn('[db] disconnected'));
  mongoose.connection.on('error', (e) => console.error('[db] error:', e.message));
}

export default connectDB;
