// Valida el mismo JWT que emite la API principal (FastAPI): comparten JWT_SECRET y algoritmo HS256.
// El token trae: sub (id del usuario), rol y correo.
const jwt = require('jsonwebtoken');
const { ErrorHttp } = require('./errores');

function autenticar(req, res, next) {
  const secreto = process.env.JWT_SECRET;
  if (!secreto) return next(new Error('Falta la variable JWT_SECRET'));
  const [tipo, token] = (req.headers.authorization || '').split(' ');
  if (tipo !== 'Bearer' || !token) return next(new ErrorHttp(401, 'Falta el token de autenticacion'));
  try {
    const payload = jwt.verify(token, secreto, { algorithms: ['HS256'] });
    req.usuario = { id: Number(payload.sub), rol: payload.rol, correo: payload.correo };
    next();
  } catch (e) {
    next(new ErrorHttp(401, e.name === 'TokenExpiredError' ? 'El token ha expirado' : 'Token invalido'));
  }
}

module.exports = { autenticar };
