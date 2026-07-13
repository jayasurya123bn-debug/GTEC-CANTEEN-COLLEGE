export const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, { 
      abortEarly: false,
      stripUnknown: true // Automatically remove unknown fields
    });

    if (error) {
      const errorMessages = error.details.map((detail) => detail.message);
      return res.status(400).json({ error: 'Validation error', details: errorMessages });
    }

    // Replace req.body with sanitized and validated value
    req.body = value;
    next();
  };
};
