import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response, Request } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('HttpExceptionFilter');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let errors: any = null;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        message = Array.isArray((exceptionResponse as any).message)
          ? (exceptionResponse as any).message.join(', ')
          : (exceptionResponse as any).message || message;
        errors = (exceptionResponse as any).error || null;
      } else {
        message = exceptionResponse as string;
      }
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    // Log the error securely - remove any large vector fields or base64 from logs
    const sanitizedBody = this.sanitizePayload(request.body);
    this.logger.error(
      `${request.method} ${request.url} - Status: ${status} - Message: ${message} - Body: ${JSON.stringify(
        sanitizedBody,
      )}`,
      exception instanceof Error ? exception.stack : undefined,
    );

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message,
      ...(errors && { errors }),
    });
  }

  private sanitizePayload(body: any): any {
    if (!body || typeof body !== 'object') return body;
    const clean = { ...body };
    if (clean.anonymized_biometric_data) {
      clean.anonymized_biometric_data = `[REDACTED_VECTOR]`;
    }
    if (clean.biometric_vector) {
      clean.biometric_vector = `[REDACTED_VECTOR]`;
    }
    if (clean.vector) {
      clean.vector = `[REDACTED_VECTOR]`;
    }
    if (clean.image_b64) {
      clean.image_b64 = '[REDACTED_BASE64_IMAGE]';
    }
    return clean;
  }
}
