const supabase = require('../config/supabase');

async function auth(req, res, next) {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Missing or invalid authorization header' });
    }

    const { data: { user }, error } = await supabase.auth.getUser(header.substring(7));
    if (error || !user) {
      return res.status(401).json({ success: false, message: 'Invalid or expired token' });
    }

    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', user.id)
      .single();

    if (userError || !userData) {
      return res.status(404).json({ success: false, message: 'User not found in database' });
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
