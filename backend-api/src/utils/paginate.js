async function paginate(query, page = 1, limit = 20) {
  const p = Math.max(1, parseInt(page) || 1);
  const l = Math.min(100, Math.max(1, parseInt(limit) || 20));
  const start = (p - 1) * l;
  const end = start + l - 1;

  const { data, error, count } = await query.range(start, end);
  if (error) throw error;

  return {
    data: data || [],
    pagination: {
      page: p,
      limit: l,
      total: count || 0,
      total_pages: count ? Math.ceil(count / l) : 0
    }
  };
}

module.exports = { paginate };
