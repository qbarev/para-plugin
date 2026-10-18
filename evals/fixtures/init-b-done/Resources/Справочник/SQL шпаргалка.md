# SQL шпаргалка

```sql
SELECT name, count(*) FROM orders GROUP BY name HAVING count(*) > 1;
```

JOIN по умолчанию — INNER.
