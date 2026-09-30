import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';

export const Modal = ({ isOpen, onClose, title, children }: any) => (
  <AnimatePresence>
    {isOpen && (
      <div className="fixed inset-0 z-[100] flex items-center justify-center p-3 sm:p-4">
        <motion.div 
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm"
        />
        <motion.div 
          initial={{ opacity: 0, scale: 0.95, y: 15 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 15 }}
          className="relative w-full max-w-2xl bg-white rounded-[2rem] sm:rounded-[2.5rem] shadow-2xl overflow-hidden my-auto max-h-[90vh] flex flex-col"
        >
          <div className="px-5 sm:px-8 py-4 sm:py-6 border-b border-slate-100 flex items-center justify-between flex-shrink-0">
            <h2 className="text-base sm:text-xl font-bold text-slate-900 font-outfit truncate pr-2">{title}</h2>
            <button onClick={onClose} className="p-2 hover:bg-slate-50 rounded-xl transition-colors flex-shrink-0">
              <X className="w-5 h-5 text-slate-400" />
            </button>
          </div>
          <div className="p-5 sm:p-8 overflow-y-auto flex-1">
            {children}
          </div>
        </motion.div>
      </div>
    )}
  </AnimatePresence>
);

export const Input = ({ label, icon: Icon, ...props }: any) => (
  <div className="space-y-2">
    {label && <label className="text-xs sm:text-sm font-bold text-slate-700 ml-1">{label}</label>}
    <div className="relative">
      {Icon && (
        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
          <Icon className="w-4 h-4 sm:w-5 sm:h-5" />
        </div>
      )}
      <input 
        {...props}
        className={`w-full ${Icon ? 'pl-11 sm:pl-12' : 'px-4 sm:px-6'} pr-4 sm:pr-6 py-3 sm:py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all font-semibold text-slate-900 text-xs sm:text-sm placeholder:text-slate-400`}
      />
    </div>
  </div>
);

export const Select = ({ label, icon: Icon, options, ...props }: any) => (
  <div className="space-y-2">
    {label && <label className="text-xs sm:text-sm font-bold text-slate-700 ml-1">{label}</label>}
    <div className="relative">
      {Icon && (
        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
          <Icon className="w-4 h-4 sm:w-5 sm:h-5" />
        </div>
      )}
      <select 
        {...props}
        className={`w-full ${Icon ? 'pl-11 sm:pl-12' : 'px-4 sm:px-6'} pr-8 sm:pr-10 py-3 sm:py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all font-semibold text-slate-900 text-xs sm:text-sm appearance-none bg-no-repeat bg-[right_1rem_center]`}
        style={{ backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2394A3B8' %3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7' /%3E%3C/svg%3E")`, backgroundSize: '1.25rem' }}
      >
        {options.map((opt: any) => (
          <option key={opt.value} value={opt.value}>{opt.label}</option>
        ))}
      </select>
    </div>
  </div>
);
