import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { Mail, Lock, ShieldCheck, Loader2, PlayCircle, LogIn } from 'lucide-react';
import { motion } from 'framer-motion';

const API_BASE_URL = 'http://localhost:5001';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await axios.post(`${API_BASE_URL}/auth/login`, { email, password });
      
      const { access_token, user } = response.data;
      
      // Store Auth Session
      localStorage.setItem('token', access_token);
      localStorage.setItem('user', JSON.stringify(user));
      
      // Redirect to Dashboard
      navigate('/');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed. Security rejection.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6 bg-[url('https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1920&q=80')] bg-cover bg-center">
      <div className="absolute inset-0 bg-emerald-900/40 backdrop-blur-md" />
      
      <motion.div 
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="relative w-full max-w-lg bg-white/80 backdrop-blur-xl p-12 rounded-[3rem] shadow-2xl border border-white/20 overflow-hidden"
      >
        <div className="absolute -top-24 -right-24 w-48 h-48 bg-emerald-500/20 rounded-full blur-3xl" />
        <div className="absolute -bottom-24 -left-24 w-48 h-48 bg-indigo-500/10 rounded-full blur-3xl" />

        <div className="text-center mb-10">
          <div className="inline-flex p-4 bg-emerald-600 rounded-[2rem] shadow-xl shadow-emerald-200 mb-6 group hover:scale-110 transition-transform cursor-pointer">
            <ShieldCheck className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-4xl font-black text-slate-900 font-outfit tracking-tight">Bloomarina</h1>
          <p className="text-emerald-600 font-black uppercase text-[10px] tracking-[0.3em] mt-1 italic">Supreme Admin Console</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div className="space-y-2">
            <label className="text-xs font-black text-slate-500 uppercase ml-2 tracking-widest">Administrative Email</label>
            <div className="relative group">
              <div className="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors">
                <Mail className="w-5 h-5" />
              </div>
              <input 
                type="email" 
                placeholder="tech@bloomarina.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full pl-16 pr-8 py-5 bg-white border-2 border-slate-100 rounded-[2rem] focus:outline-none focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all font-bold text-slate-900"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-black text-slate-500 uppercase ml-2 tracking-widest">Secure Credentials</label>
            <div className="relative group">
              <div className="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors">
                <Lock className="w-5 h-5" />
              </div>
              <input 
                type="password" 
                placeholder="••••••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full pl-16 pr-8 py-5 bg-white border-2 border-slate-100 rounded-[2rem] focus:outline-none focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all font-bold text-slate-900"
                required
              />
            </div>
          </div>

          {error && (
            <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="p-4 bg-red-50 text-red-600 rounded-2xl text-xs font-bold text-center border border-red-100">
               ⚠️ {error}
            </motion.div>
          )}

          <button 
            type="submit"
            disabled={loading}
            className="w-full py-6 bg-slate-900 text-white rounded-[2rem] font-black text-lg flex items-center justify-center gap-3 shadow-2xl hover:bg-emerald-600 hover:shadow-emerald-200 transition-all active:scale-95 disabled:opacity-70 group"
          >
            {loading ? <Loader2 className="w-6 h-6 animate-spin" /> : <LogIn className="w-6 h-6 group-hover:translate-x-1 transition-transform" />}
            {loading ? 'Authenticating...' : 'Access Console'}
          </button>
        </form>

        <div className="mt-10 text-center">
          <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest leading-loose">
            Project Grocery Delivery • Bloomarina Instamart<br/>
            © 2026 High Security Cloud Infrastructure
          </p>
        </div>
      </motion.div>
    </div>
  );
}
