const supabase = require('../config/supabase');
const chatWS = require('../services/chatWebSocket');

const localMessagesMap = new Map(); // order_id -> Array of messages

const DEMO_CONVERSATIONS = [
  {
    order_id: 'order_1',
    peer_id: '22222222-2222-2222-2222-222222222222',
    peer_name: "Ahmad Syifa’ul Falakhul K.",
    peer_role: 'collector',
    item_type: 'Kardus & Plastik',
    last_message: 'Permisi kak saya sedang di perjalanan, Perkiraan 10 Me..',
    last_message_time: new Date().toISOString(),
    unread_count: 2
  },
  {
    order_id: 'order_2',
    peer_id: '22222222-2222-2222-2222-222222222223',
    peer_name: 'Pak Sutarjo',
    peer_role: 'collector',
    item_type: 'Minyak Jelantah',
    last_message: 'Baik kak',
    last_message_time: new Date(Date.now() - 3600000).toISOString(),
    unread_count: 0
  }
];

// --- PROFILE ---
async function updateProfile(req, res, next) {
  try {
    const userId = req.user.id;
    const { name, phone, avatar_url } = req.body;

    const { data, error } = await supabase
      .from('users')
      .update({ name, phone, avatar_url })
      .eq('id', userId)
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

// --- ADDRESSES ---
async function getAddresses(req, res, next) {
  try {
    const { data, error } = await supabase
      .from('user_addresses')
      .select('*')
      .eq('user_id', req.user.id)
      .order('is_primary', { ascending: false });

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

async function addAddress(req, res, next) {
  try {
    const { label, address, latitude, longitude, is_primary } = req.body;
    
    if (!latitude || !longitude) {
      return res.status(400).json({ success: false, message: 'Latitude and longitude are required' });
    }

    if (is_primary) {
      await supabase.from('user_addresses').update({ is_primary: false }).eq('user_id', req.user.id);
    }

    const { data, error } = await supabase
      .from('user_addresses')
      .insert({
        user_id: req.user.id,
        label, address, is_primary: is_primary || false,
        location: `POINT(${longitude} ${latitude})`
      })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data });
  } catch (error) { next(error); }
}

async function deleteAddress(req, res, next) {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('user_addresses')
      .delete()
      .eq('id', id)
      .eq('user_id', req.user.id);

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.json({ success: true, message: 'Address deleted successfully' });
  } catch (error) { next(error); }
}

// --- CHAT (ORDER MESSAGES & CONVERSATIONS) ---
async function sendMessage(req, res, next) {
  try {
    const { id: order_id } = req.params;
    const msgText = (req.body.message || req.body.text || '').trim();
    if (!msgText) {
      return res.status(400).json({ success: false, message: 'Pesan tidak boleh kosong' });
    }

    const userId = req.user?.id || 'demo_user';
    const userRole = req.user?.role || 'user';
    const userName = req.user?.name || (userRole === 'collector' ? 'Kolektor' : 'Warga');

    const messageObj = {
      id: 'msg_' + Date.now() + '_' + Math.random().toString(36).substr(2, 5),
      order_id,
      sender_id: userId,
      sender_name: userName,
      sender_role: userRole,
      message: msgText,
      text: msgText,
      created_at: new Date().toISOString(),
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };

    // Try saving to DB if order_id is valid UUID
    try {
      const { data, error } = await supabase
        .from('order_messages')
        .insert({ order_id, sender_id: userId, message: msgText })
        .select()
        .single();
      
      if (!error && data) {
        messageObj.id = data.id;
        messageObj.created_at = data.created_at;
      }
    } catch (e) {
      // Fallback to local map
    }

    // Save to local in-memory store for instant sync
    if (!localMessagesMap.has(order_id)) {
      localMessagesMap.set(order_id, []);
    }
    localMessagesMap.get(order_id).push(messageObj);

    // Real-time broadcast via WebSocket
    try {
      chatWS.broadcastMessage(order_id, {
        ...messageObj,
        isMe: false
      });
    } catch (err) {}

    return res.status(201).json({
      success: true,
      data: messageObj,
      message: msgText
    });
  } catch (error) { next(error); }
}

async function getMessages(req, res, next) {
  try {
    const { id: order_id } = req.params;
    const currentUserId = req.user?.id || 'demo_user';
    const currentUserRole = req.user?.role || 'user';

    let dbMessages = [];
    try {
      const { data, error } = await supabase
        .from('order_messages')
        .select('*')
        .eq('order_id', order_id)
        .order('created_at', { ascending: true });
      
      if (!error && data) {
        dbMessages = data;
      }
    } catch (e) {}

    let localMsgs = localMessagesMap.get(order_id);
    if (!localMsgs || localMsgs.length === 0) {
      localMsgs = [
        {
          id: 'msg_seed_1',
          order_id,
          sender_id: 'user_1',
          sender_role: 'user',
          message: 'Halo mas kolektor, posisi di mana? Pesanan penjemputan sampah saya sudah siap ya.',
          text: 'Halo mas kolektor, posisi di mana? Pesanan penjemputan sampah saya sudah siap ya.',
          created_at: new Date().toISOString(),
          time: '12:15'
        },
        {
          id: 'msg_seed_2',
          order_id,
          sender_id: 'collector_1',
          sender_role: 'collector',
          message: 'Halo kak, saya sedang dalam perjalanan menuju lokasi Anda. Perkiraan 3-5 menit lagi sampai.',
          text: 'Halo kak, saya sedang dalam perjalanan menuju lokasi Anda. Perkiraan 3-5 menit lagi sampai.',
          created_at: new Date().toISOString(),
          time: '12:16'
        }
      ];
      localMessagesMap.set(order_id, localMsgs);
    }
    
    // Merge DB messages and local messages, avoiding duplicates by id
    const messageMap = new Map();
    for (const m of dbMessages) {
      const timeStr = m.created_at ? new Date(m.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '';
      messageMap.set(m.id, {
        id: m.id,
        order_id: m.order_id,
        sender_id: m.sender_id,
        sender_role: m.sender_role || 'user',
        message: m.message,
        text: m.message,
        created_at: m.created_at,
        time: timeStr,
        isMe: m.sender_id === currentUserId
      });
    }

    for (const m of localMsgs) {
      if (!messageMap.has(m.id)) {
        messageMap.set(m.id, {
          ...m,
          isMe: m.sender_id === currentUserId || (currentUserRole === 'collector' ? m.sender_role === 'collector' : m.sender_role === 'user')
        });
      }
    }

    const result = Array.from(messageMap.values());
    return res.json({
      success: true,
      data: result,
      messages: result
    });
  } catch (error) { next(error); }
}

async function getChats(req, res, next) {
  try {
    const currentUserId = req.user?.id;
    const currentUserRole = req.user?.role || 'user';

    const conversations = [];

    // Fetch user/collector orders from DB
    try {
      let query = supabase.from('orders').select('*');
      if (currentUserRole === 'user') {
        query = query.eq('user_id', currentUserId);
      } else if (currentUserRole === 'collector') {
        query = query.eq('collector_id', currentUserId);
      }

      const { data: orders, error } = await query;

      if (!error && orders && orders.length > 0) {
        // Fetch peer users info
        const peerIds = orders
          .map(o => (currentUserRole === 'user' ? o.collector_id : o.user_id))
          .filter(Boolean);

        let peersMap = new Map();
        if (peerIds.length > 0) {
          const { data: peers } = await supabase
            .from('users')
            .select('id, name, phone, avatar_url, role')
            .in('id', peerIds);
          
          if (peers) {
            peers.forEach(p => peersMap.set(p.id, p));
          }
        }

        for (const order of orders) {
          const peerId = currentUserRole === 'user' ? order.collector_id : order.user_id;
          const peer = peersMap.get(peerId);

          let lastMessage = 'Obrolan telah dibuka';
          let lastTime = order.created_at;

          const localMsgs = localMessagesMap.get(order.id) || [];
          if (localMsgs.length > 0) {
            lastMessage = localMsgs[localMsgs.length - 1].message;
            lastTime = localMsgs[localMsgs.length - 1].created_at;
          } else {
            const { data: dbMsg } = await supabase
              .from('order_messages')
              .select('message, created_at')
              .eq('order_id', order.id)
              .order('created_at', { ascending: false })
              .limit(1);

            if (dbMsg && dbMsg.length > 0) {
              lastMessage = dbMsg[0].message;
              lastTime = dbMsg[0].created_at;
            }
          }

          conversations.push({
            order_id: order.id,
            peer_id: peerId || 'system',
            peer_name: peer?.name || (currentUserRole === 'user' ? 'Pak Sutarjo (Kolektor)' : 'Warga EcoPoint'),
            peer_role: peer?.role || (currentUserRole === 'user' ? 'collector' : 'user'),
            peer_phone: peer?.phone || '',
            item_type: order.item_type || 'Sampah Daur Ulang',
            last_message: lastMessage,
            last_message_time: lastTime,
            unread_count: 0
          });
        }
      }
    } catch (e) {}

    // Combine with demo threads if DB returned no conversations
    if (conversations.length === 0) {
      for (const demo of DEMO_CONVERSATIONS) {
        const localMsgs = localMessagesMap.get(demo.order_id) || [];
        if (localMsgs.length > 0) {
          demo.last_message = localMsgs[localMsgs.length - 1].message;
          demo.last_message_time = localMsgs[localMsgs.length - 1].created_at;
        }
        conversations.push(demo);
      }
    }

    res.json({ success: true, data: conversations });
  } catch (error) { next(error); }
}

async function deleteMessage(req, res, next) {
  try {
    const { messageId } = req.params;
    const { error } = await supabase.from('order_messages').delete().eq('id', messageId);
    if (error) return res.status(400).json({ success: false, message: error.message });

    res.json({ success: true, message: 'Message deleted successfully' });
  } catch (error) { next(error); }
}

// --- RATINGS & REVIEWS ---
async function addReview(req, res, next) {
  try {
    const { id: order_id } = req.params;
    const { reviewee_id, rating, comment } = req.body;

    if (!reviewee_id) {
      return res.status(400).json({ success: false, message: 'reviewee_id is required' });
    }

    const { data, error } = await supabase
      .from('order_reviews')
      .insert({ order_id, reviewer_id: req.user.id, reviewee_id, rating, comment })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data });
  } catch (error) { next(error); }
}

async function getUserReviews(req, res, next) {
  try {
    const { data, error } = await supabase
      .from('order_reviews')
      .select('*')
      .or(`reviewer_id.eq.${req.user.id},reviewee_id.eq.${req.user.id}`)
      .order('created_at', { ascending: false });

    if (error) {
      return res.json({ success: true, data: [] });
    }
    res.json({ success: true, data: data || [] });
  } catch (error) { next(error); }
}

// --- PAYMENTS (TOPUP & WITHDRAWAL) ---
async function requestWithdrawal(req, res, next) {
  try {
    const { amount, bank_name, account_number } = req.body;
    
    const { data: user } = await supabase.from('users').select('wallet_balance').eq('id', req.user.id).single();
    if (user.wallet_balance < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient balance' });
    }

    await supabase.from('users').update({ wallet_balance: user.wallet_balance - amount }).eq('id', req.user.id);

    const { data, error } = await supabase
      .from('withdrawals')
      .insert({ user_id: req.user.id, amount, bank_name, account_number, status: 'pending' })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data, message: 'Withdrawal requested' });
  } catch (error) { next(error); }
}

async function requestTopup(req, res, next) {
  try {
    const { amount, payment_method } = req.body;
    
    const { data: user } = await supabase.from('users').select('wallet_balance').eq('id', req.user.id).single();
    await supabase.from('users').update({ wallet_balance: Number(user.wallet_balance) + Number(amount) }).eq('id', req.user.id);

    const { data, error } = await supabase
      .from('topups')
      .insert({ user_id: req.user.id, amount, payment_method, status: 'completed' })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data, message: 'Top up successful' });
  } catch (error) { next(error); }
}

async function deleteAccount(req, res, next) {
  try {
    const { error: dbError } = await supabase.from('users').delete().eq('id', req.user.id);
    if (dbError) return res.status(400).json({ success: false, message: dbError.message });
    
    const { error: authError } = await supabase.auth.admin.deleteUser(req.user.id);
    if (authError) return res.status(400).json({ success: false, message: authError.message });

    res.json({ success: true, message: 'Account deleted successfully' });
  } catch (error) { next(error); }
}

function parseLocation(loc) {
  if (!loc) return null;
  if (loc.type === 'Point' && loc.coordinates) return { lng: loc.coordinates[0], lat: loc.coordinates[1] };
  if (typeof loc === 'string' && loc.startsWith('01')) {
    const buf = Buffer.from(loc, 'hex');
    return { lng: buf.readDoubleLE(9), lat: buf.readDoubleLE(17) };
  }
  const m = String(loc).match(/POINT\(([^ ]+) ([^ ]+)\)/);
  if (m) return { lng: parseFloat(m[1]), lat: parseFloat(m[2]) };
  return null;
}

function haversine(lng1, lat1, lng2, lat2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// --- MAP / ROUTE ---
async function getNearbyCollectors(req, res, next) {
  try {
    const { lat, lng } = req.query;
    const userLat = lat ? parseFloat(lat) : -7.1185;
    const userLng = lng ? parseFloat(lng) : 112.4166;

    let collectors = [];
    try {
      const { data: dbCollectors } = await supabase
        .from('users')
        .select('id, name, rating, location, is_online, phone')
        .eq('role', 'collector');

      if (dbCollectors && dbCollectors.length > 0) {
        collectors = dbCollectors.map((c, idx) => {
          let cLat = -7.1150 + (idx * 0.003);
          let cLng = 112.4200 + (idx * 0.004);
          if (c.location) {
            const loc = parseLocation(c.location);
            if (loc) {
              cLat = loc.lat;
              cLng = loc.lng;
            }
          }
          const distKm = (haversine(userLng, userLat, cLng, cLat) / 1000).toFixed(1);
          const isOnline = c.is_online !== false;
          return {
            id: c.id,
            name: c.name || 'Mitra Kolektor',
            rating: c.rating || 4.8,
            lat: cLat,
            lng: cLng,
            distance_km: parseFloat(distKm),
            status: isOnline ? 'online' : 'offline',
            is_online: isOnline,
            phone: c.phone || '081234567890'
          };
        });
      }
    } catch (e) {}

    if (collectors.length === 0) {
      collectors = [
        {
          id: 'c1',
          name: 'Hendra Pengepul (Jelantah & Besi)',
          rating: 4.8,
          lat: -7.1150,
          lng: 112.4200,
          distance_km: 0.8,
          status: 'online',
          is_online: true,
          phone: '081234567890',
        },
        {
          id: 'c2',
          name: 'Bapak Sutarjo (Kardus & Plastik)',
          rating: 4.6,
          lat: -7.1220,
          lng: 112.4100,
          distance_km: 1.4,
          status: 'online',
          is_online: true,
          phone: '081987654321',
        },
        {
          id: 'c3',
          name: 'Mas Budi Kolektor Daur Ulang',
          rating: 4.9,
          lat: -7.1110,
          lng: 112.4250,
          distance_km: 2.1,
          status: 'offline',
          is_online: false,
          phone: '085711223344',
        }
      ];
    }

    res.json({ success: true, data: collectors });
  } catch (error) { next(error); }
}

async function getCollectorWallet(req, res, next) {
  try {
    const { data, error } = await supabase.from('users').select('wallet_balance').eq('id', req.user.id).single();
    if (error) return res.status(400).json({ success: false, message: error.message });

    res.json({ success: true, data });
  } catch (error) { next(error); }
}

module.exports = {
  updateProfile,
  getAddresses, addAddress, deleteAddress,
  sendMessage, getMessages, getChats, deleteMessage,
  addReview, getUserReviews,
  requestWithdrawal, requestTopup,
  deleteAccount, getCollectorWallet,
  getNearbyCollectors
};
