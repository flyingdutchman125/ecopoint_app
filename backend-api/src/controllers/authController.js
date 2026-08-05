const supabase = require('../config/supabase');

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return res.status(401).json({ success: false, message: error.message });

    // Fetch user profile from public.users table to get full details (role, name, phone, etc.)
    let dbUser = null;
    try {
      const { data: dbData } = await supabase
        .from('users')
        .select('*')
        .eq('id', data.user.id)
        .single();
      dbUser = dbData;
    } catch (e) {
      console.warn('Failed to fetch user profile from DB on login:', e.message || e);
    }

    const role = dbUser?.role || data.user.user_metadata?.role || 'user';
    const name = dbUser?.name || data.user.user_metadata?.name || data.user.email?.split('@')[0];

    const userProfile = {
      id: data.user.id,
      email: data.user.email,
      name: name,
      role: role,
      phone: dbUser?.phone || data.user.user_metadata?.phone || null,
      city: dbUser?.city || data.user.user_metadata?.city || null,
      address: dbUser?.address || null,
      subdistrict: dbUser?.subdistrict || null,
      wallet_balance: dbUser?.wallet_balance ?? 0,
      eco_points: dbUser?.eco_points ?? 0,
      avatar_url: dbUser?.avatar_url || null,
      user_metadata: {
        ...data.user.user_metadata,
        role: role,
        name: name,
      },
    };

    res.json({
      success: true,
      data: {
        token: data.session.access_token,
        user: userProfile
      }
    });
  } catch (error) { next(error); }
}

async function register(req, res, next) {
  try {
    const {
      email,
      password,
      name,
      phone,
      city,
      address,
      subdistrict,
      role,
      consent_sorting_anorganic,
      business_name,
      vehicle_type,
      vehicle_plate,
      ktp_url,
    } = req.body;

    if (!email || !password || !name || !phone || !city || !address || !subdistrict) {
      return res.status(400).json({
        success: false,
        message: 'Email, password, name, phone, city, address, and subdistrict are required',
      });
    }

    const validRole = ['user', 'collector', 'admin'].includes(role) ? role : 'user';
    const consentSorting = Boolean(consent_sorting_anorganic);

    // If registering as collector, ensure collector fields are present (basic validation)
    if (validRole === 'collector') {
      // business_name, vehicle_type, vehicle_plate and ktp_url are encouraged but made optional here
      // (caller may upload ktp after registering). If strict validation desired, uncomment the below check.
      // if (!business_name || !vehicle_type || !vehicle_plate) {
      //   return res.status(400).json({ success: false, message: 'Business name, vehicle type and vehicle plate are required for collectors' });
      // }
    }

    let authUser;
    const adminRes = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { role: validRole, phone, city, name },
    });

    if (adminRes.error) {
      console.warn('Admin createUser failed, falling back to public signUp:', adminRes.error.message);
      const signupRes = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { role: validRole, phone, city, name },
        },
      });
      if (signupRes.error) {
        return res.status(400).json({ success: false, message: signupRes.error.message });
      }
      authUser = signupRes.data.user;
    } else {
      authUser = adminRes.data.user;
    }

    let dbError;
    try {
      const insertData = {
        id: authUser.id,
        email,
        name,
        role: validRole,
        phone,
        city,
        wallet_balance: 0,
        eco_points: 0,
      };
      if (address) insertData.address = address;
      if (subdistrict) insertData.subdistrict = subdistrict;
      if (consentSorting !== undefined) insertData.consent_sorting_anorganic = consentSorting;

      // Retry dropping whichever optional column the live schema is missing
      // (migration_v4 columns may not be applied yet). Core columns are never dropped.
      const optional = ['city', 'address', 'subdistrict', 'consent_sorting_anorganic'];
      for (let attempt = 0; attempt <= optional.length; attempt++) {
        const insertRes = await supabase.from('users').insert(insertData);
        dbError = insertRes.error;
        if (!dbError) break;
        const missing = optional.find(
          (c) => insertData[c] !== undefined && (
            dbError.message?.includes(`'${c}'`) ||
            dbError.message?.includes(`"${c}"`)
          )
        );
        if (!missing) break;
        console.warn(`users.${missing} missing in schema, retrying without it`);
        delete insertData[missing];
      }
    } catch (err) {
      dbError = err;
    }

    if (dbError) {
      // Rollback the auth user, otherwise it can log in but has no profile row.
      console.error('Register DB insert failed:', dbError.message || dbError);
      await supabase.auth.admin.deleteUser(authUser.id).catch(() => {});
      return res.status(400).json({
        success: false,
        message: `Registrasi gagal menyimpan profil: ${dbError.message || dbError}`,
      });
    }

    // If collector-specific info provided, save to collectors table
    if (validRole === 'collector') {
      try {
        const { error: collectorError } = await supabase.from('collectors').insert({
          user_id: authUser.id,
          business_name: business_name || null,
          vehicle_type: vehicle_type || null,
          vehicle_plate: vehicle_plate || null,
          ktp_url: ktp_url || null,
        });
        if (collectorError) {
          // log but do not block registration completion; return warning in response
          console.warn('Failed to insert collector details:', collectorError.message);
        }
      } catch (e) {
        console.warn('Collector insert exception:', e.message || e);
      }
    }

    res.status(201).json({
      success: true,
      data: {
        id: authUser.id,
        email,
        name,
        role: validRole,
        phone,
        city,
        address,
        subdistrict,
      },
    });
  } catch (error) {
    next(error);
  }
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

async function changePassword(req, res, next) {
  try {
    const { current_password, new_password } = req.body;
    if (!new_password) {
      return res.status(400).json({ success: false, message: 'New password is required' });
    }

    const { error } = await supabase.auth.admin.updateUserById(req.user.id, { password: new_password });
    
    if (error) {
      return res.status(400).json({ success: false, message: error.message });
    }

    res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    next(error);
  }
}

module.exports = { login, register, forgotPassword, changePassword };
