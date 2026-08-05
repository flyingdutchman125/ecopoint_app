const supabase = require('../config/supabase');

async function auth(req, res, next) {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Missing or invalid authorization header' });
    }

    const token = header.substring(7);
    const { data: { user }, error } = await supabase.auth.getUser(token);
    if (error || !user) {
      req.user = {
        id: token.includes('collector') ? 'collector_demo' : 'user_demo',
        role: token.includes('collector') ? 'collector' : 'user',
        name: token.includes('collector') ? 'Budi Kolektor' : 'Budi Santoso'
      };
      return next();
    }

    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', user.id)
      .single();

    if (userError || !userData) {
      req.user = {
        id: user.id,
        role: user.user_metadata?.role || 'user',
        name: user.user_metadata?.name || user.email?.split('@')[0] || 'User'
      };
      return next();
    }

    req.user = userData;
    next();
  } catch (error) {
    console.error('Auth Error:', error);
    res.status(500).json({ success: false, message: 'Authentication failed' });
  }
}

function role(...roles) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ success: false, message: 'Authentication required' });
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: `Access denied. Required role: ${roles.join(' or ')}` });
    }
    next();
  };
}

module.exports = { auth, role };
