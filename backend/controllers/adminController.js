const db = require('../config/db');

exports.getPendingCollectors = async (req, res) => {
  try {
    const [collectors] = await db.execute(
      'SELECT id, name, email, phone, vehicle_type, plate_number, ktp_photo_url, created_at FROM users WHERE role = ? AND status = ?',
      ['collector', 'pending_verification']
    );
    res.status(200).json(collectors);
  } catch (error) {
    console.error('Error fetching pending collectors:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.verifyCollector = async (req, res) => {
  try {
    const { id } = req.params;
    const { action } = req.body; // 'approve' or 'reject'

    if (!['approve', 'reject'].includes(action)) {
      return res.status(400).json({ message: 'Invalid action' });
    }

    const newStatus = action === 'approve' ? 'active' : 'rejected';

    const [result] = await db.execute('UPDATE users SET status = ? WHERE id = ? AND role = ?', [newStatus, id, 'collector']);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Collector not found' });
    }

    res.status(200).json({ message: `Collector ${action}d successfully` });
  } catch (error) {
    console.error('Error verifying collector:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
