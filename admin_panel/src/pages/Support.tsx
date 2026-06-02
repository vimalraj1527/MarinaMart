import { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { Send, MessageSquare, User, Phone, CornerDownLeft, Loader2 } from 'lucide-react';
import api from '../services/api';
import { formatToIST } from '../services/dateUtils';

export default function Support() {
  const [conversations, setConversations] = useState<any[]>([]);
  const [selectedCustomerId, setSelectedCustomerId] = useState<string | null>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [inputText, setInputText] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [isLoadingChats, setIsLoadingChats] = useState(true);
  const [isLoadingMessages, setIsLoadingMessages] = useState(false);

  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Load active chats/conversations on mount
  const fetchConversations = async () => {
    try {
      const res = await api.get('/support/conversations');
      setConversations(res.data);
    } catch (err) {
      console.error('Error fetching conversations:', err);
    } finally {
      setIsLoadingChats(false);
    }
  };

  // Load messages for the selected customer
  const fetchMessages = async (customerId: string, silent = false) => {
    if (!silent) setIsLoadingMessages(true);
    try {
      const res = await api.get(`/support/messages/${customerId}`);
      setMessages(res.data);
    } catch (err) {
      console.error('Error fetching messages:', err);
    } finally {
      if (!silent) setIsLoadingMessages(false);
    }
  };

  useEffect(() => {
    fetchConversations();
    // Poll conversations list every 5 seconds
    const interval = setInterval(fetchConversations, 5000);
    return () => clearInterval(interval);
  }, []);

  // Poll messages every 3 seconds if a customer conversation is selected
  useEffect(() => {
    if (!selectedCustomerId) return;
    fetchMessages(selectedCustomerId);

    const interval = setInterval(() => {
      fetchMessages(selectedCustomerId, true);
    }, 3000);

    return () => clearInterval(interval);
  }, [selectedCustomerId]);

  // Scroll to bottom whenever messages list updates
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCustomerId || !inputText.trim()) return;

    try {
      setIsSending(true);
      const messageToSend = inputText.trim();
      setInputText('');
      
      const res = await api.post('/support/message', {
        message: messageToSend,
        customerId: selectedCustomerId,
      });

      setMessages(prev => [...prev, res.data]);
      fetchConversations(); // Refresh list to update previews
    } catch (err) {
      console.error('Error sending message:', err);
    } finally {
      setIsSending(false);
    }
  };

  const getSelectedCustomer = () => {
    return conversations.find(c => c.customerId === selectedCustomerId);
  };

  return (
    <div className="h-[calc(100vh-12rem)] flex bg-white rounded-3xl border border-slate-100 overflow-hidden shadow-xl shadow-slate-100/50">
      {/* Sidebar List */}
      <div className="w-80 border-r border-slate-100 flex flex-col bg-slate-50/50">
        <div className="p-6 border-b border-slate-100 bg-white">
          <h2 className="text-lg font-bold text-slate-900 flex items-center gap-2">
            <MessageSquare className="w-5 h-5 text-emerald-600" />
            Support Inbox
          </h2>
          <p className="text-xs text-slate-400 font-semibold mt-1">Real-time customer messages</p>
        </div>

        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {isLoadingChats ? (
            <div className="flex flex-col items-center justify-center h-48 text-slate-400 gap-2">
              <Loader2 className="w-6 h-6 animate-spin text-emerald-600" />
              <span className="text-xs font-semibold">Loading inbox...</span>
            </div>
          ) : conversations.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-48 text-slate-400 text-center px-4">
              <MessageSquare className="w-8 h-8 opacity-20 mb-3" />
              <p className="text-sm font-bold">No chats yet</p>
              <p className="text-[11px] opacity-60">Customer queries will appear here.</p>
            </div>
          ) : (
            conversations.map((conv) => {
              const isActive = conv.customerId === selectedCustomerId;
              return (
                <motion.div
                  key={conv.customerId}
                  whileHover={{ scale: 1.01 }}
                  whileTap={{ scale: 0.99 }}
                  onClick={() => setSelectedCustomerId(conv.customerId)}
                  className={`p-4 rounded-2xl cursor-pointer border transition-all duration-300 ${
                    isActive
                      ? 'bg-emerald-600 border-emerald-600 shadow-lg shadow-emerald-600/10 text-white'
                      : 'bg-white border-slate-100 hover:border-slate-200 text-slate-700'
                  }`}
                >
                  <div className="flex justify-between items-start mb-1">
                    <p className={`font-extrabold text-sm ${isActive ? 'text-white' : 'text-slate-900'}`}>
                      {conv.customerName}
                    </p>
                    <p className={`text-[9px] font-bold ${isActive ? 'text-emerald-100' : 'text-slate-400'}`}>
                      {formatToIST(conv.lastMessageTime).split(',')[1]?.trim() || ''}
                    </p>
                  </div>
                  <p className={`text-xs truncate font-medium ${isActive ? 'text-emerald-50' : 'text-slate-400'}`}>
                    {conv.lastMessageSender === 'Admin' ? 'You: ' : ''}
                    {conv.lastMessage}
                  </p>
                </motion.div>
              );
            })
          )}
        </div>
      </div>

      {/* Chat Windows */}
      <div className="flex-1 flex flex-col bg-white">
        {selectedCustomerId ? (
          <>
            {/* Header info */}
            {(() => {
              const customer = getSelectedCustomer();
              return (
                <div className="px-8 py-5 border-b border-slate-100 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="p-3 bg-emerald-50 rounded-2xl text-emerald-600">
                      <User className="w-5 h-5" />
                    </div>
                    <div>
                      <h3 className="font-extrabold text-slate-900">{customer?.customerName}</h3>
                      <p className="text-xs text-slate-400 font-semibold flex items-center gap-1">
                        <Phone className="w-3 h-3" />
                        {customer?.customerPhone}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })()}

            {/* Messages Scroll Area */}
            <div className="flex-1 overflow-y-auto p-8 space-y-6">
              {isLoadingMessages ? (
                <div className="flex items-center justify-center h-full">
                  <Loader2 className="w-8 h-8 animate-spin text-emerald-600" />
                </div>
              ) : (
                messages.map((msg, index) => {
                  const isAdmin = msg.senderType === 'Admin';
                  return (
                    <div
                      key={msg.id || index}
                      className={`flex ${isAdmin ? 'justify-end' : 'justify-start'}`}
                    >
                      <div
                        className={`max-w-[70%] p-4 rounded-3xl shadow-sm ${
                          isAdmin
                            ? 'bg-emerald-600 text-white rounded-tr-none'
                            : 'bg-slate-100 text-slate-800 rounded-tl-none'
                        }`}
                      >
                        <p className="text-sm font-medium leading-relaxed">{msg.message}</p>
                        <p
                          className={`text-[9px] font-bold mt-1 text-right ${
                            isAdmin ? 'text-emerald-100' : 'text-slate-400'
                          }`}
                        >
                          {formatToIST(msg.createdAt)}
                        </p>
                      </div>
                    </div>
                  );
                })
              )}
              <div ref={messagesEndRef} />
            </div>

            {/* Input bar */}
            <form onSubmit={handleSendMessage} className="p-6 border-t border-slate-100 flex gap-4">
              <input
                type="text"
                value={inputText}
                onChange={e => setInputText(e.target.value)}
                placeholder="Type a message to reply..."
                className="flex-1 px-5 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:border-emerald-500 focus:bg-white text-sm font-medium transition-all text-slate-800"
              />
              <button
                type="submit"
                disabled={isSending || !inputText.trim()}
                className="px-6 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-40 text-white font-bold rounded-2xl flex items-center gap-2 transition-all shadow-lg shadow-emerald-600/10 cursor-pointer"
              >
                {isSending ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    <Send className="w-4 h-4" />
                    <span>Send</span>
                  </>
                )}
              </button>
            </form>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-slate-400 p-8">
            <div className="w-16 h-16 bg-slate-50 border border-slate-100 rounded-3xl flex items-center justify-center text-slate-300 mb-4">
              <MessageSquare className="w-8 h-8" />
            </div>
            <h3 className="font-extrabold text-slate-800 text-base">No Customer Selected</h3>
            <p className="text-xs opacity-60 mt-1 max-w-[280px] text-center">
              Select a conversation from the sidebar to view active messages and send support replies.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
