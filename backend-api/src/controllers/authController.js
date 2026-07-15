const supabase = require('../config/supabase');

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return res.status(401).json({ success: false, message: error.message });

    res.json({
      success: true,
      data: {
        token: data.session.access_token,
        user: data.user
      }
    });
  } catch (error) { next(error); }
}

async function register(req, res, next) {
  try {
    const { email, password, name, role } = req.body;
    if (!email || !password || !name) {
      return res.status(400).json({ success: false, message: 'Email, password, and name are required' });
    }

    const validRole = ['user', 'collector', 'admin'].includes(role) ? role : 'user';

    const { data, error } = await supabase.auth.admin.createUser({
      email, password, email_confirm: true,
      user_metadata: { role: validRole }
    });

    if (error) return res.status(400).json({ success: false, message: error.message });

    const { error: dbError } = await supabase.from('users').insert({
      id: data.user.id, email, name, role: validRole, wallet_balance: 0, eco_points: 0
    });

    if (dbError) return res.status(400).json({ success: false, message: dbError.message });

    res.status(201).json({ success: true, data: { id: data.user.id, email, name, role: validRole } });
  } catch (error) { next(error); }
}

async function forgotPassword(req, res, next) {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }
    // Dummy implementation. In real app, call Supabase auth to send reset password email
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: 'com.ecopoint.app://reset-password',
    });
    if (error) return res.status(400).json({ success: false, message: error.message });

    res.json({ success: true, message: 'Password reset instructions sent to email.' });
  } catch (error) { next(error); }
}

module.exports = { login, register, forgotPassword };
