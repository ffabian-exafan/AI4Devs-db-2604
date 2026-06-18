import { Request, Response } from 'express';
import { addCandidateController, getCandidateByIdController } from './candidateController';
import * as candidateService from '../../application/services/candidateService';

jest.mock('../../application/services/candidateService', () => ({
    addCandidate: jest.fn(),
    getCandidateById: jest.fn(),
}));

const mockRequest = (params: any, body: any = {}): Partial<Request> => ({
    params,
    body,
});

const mockResponse = (): Partial<Response> => {
    const res: Partial<Response> = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    return res;
};

describe('addCandidateController', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should add a candidate successfully and return status 201 with a success message', async () => {
        const candidateData = { firstName: 'John', lastName: 'Doe', email: 'john.doe@example.com' };
        const savedCandidate = { id: 1, ...candidateData };
        (candidateService.addCandidate as jest.Mock).mockResolvedValue(savedCandidate);

        const req = mockRequest({}, candidateData);
        const res = mockResponse();

        await addCandidateController(req as Request, res as Response);

        expect(candidateService.addCandidate).toHaveBeenCalledWith(candidateData);
        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Candidate added successfully',
            data: savedCandidate,
        });
    });

    it('should handle validation errors and return status 400 with an error message', async () => {
        const candidateData = { firstName: 'John', email: 'invalid-email' };
        (candidateService.addCandidate as jest.Mock).mockRejectedValue(new Error('Invalid email'));

        const req = mockRequest({}, candidateData);
        const res = mockResponse();

        await addCandidateController(req as Request, res as Response);

        expect(candidateService.addCandidate).toHaveBeenCalledWith(candidateData);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Error adding candidate',
            error: 'Invalid email',
        });
    });

    it('should handle unique constraint errors and return status 400 with an error message', async () => {
        const candidateData = { firstName: 'John', lastName: 'Doe', email: 'john.doe@example.com' };
        (candidateService.addCandidate as jest.Mock).mockRejectedValue(new Error('The email already exists in the database'));

        const req = mockRequest({}, candidateData);
        const res = mockResponse();

        await addCandidateController(req as Request, res as Response);

        expect(candidateService.addCandidate).toHaveBeenCalledWith(candidateData);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Error adding candidate',
            error: 'The email already exists in the database',
        });
    });

    it('should handle unknown errors and return status 400 with a generic error message', async () => {
        const candidateData = { firstName: 'John', lastName: 'Doe', email: 'john.doe@example.com' };
        (candidateService.addCandidate as jest.Mock).mockRejectedValue({});

        const req = mockRequest({}, candidateData);
        const res = mockResponse();

        await addCandidateController(req as Request, res as Response);

        expect(candidateService.addCandidate).toHaveBeenCalledWith(candidateData);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Error adding candidate',
            error: 'Unknown error',
        });
    });
});

describe('getCandidateByIdController', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should return candidate information for a valid ID', async () => {
        const candidateId = 1;
        const candidateData = { id: candidateId, firstName: 'John', lastName: 'Doe', email: 'john.doe@example.com', phone: '1234567890', address: '123 Main St' };
        (candidateService.getCandidateById as jest.Mock).mockResolvedValue(candidateData);

        const req = mockRequest({ id: candidateId });
        const res = mockResponse();

        await getCandidateByIdController(req as Request, res as Response);

        expect(candidateService.getCandidateById).toHaveBeenCalledWith(candidateId);
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(candidateData);
    });

    it('should return 400 for an invalid ID', async () => {
        const req = mockRequest({ id: 'invalid' });
        const res = mockResponse();

        await getCandidateByIdController(req as Request, res as Response);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Invalid candidate ID',
        });
    });

    it('should return 404 if candidate is not found', async () => {
        const candidateId = 1;
        (candidateService.getCandidateById as jest.Mock).mockResolvedValue(null);

        const req = mockRequest({ id: candidateId });
        const res = mockResponse();

        await getCandidateByIdController(req as Request, res as Response);

        expect(candidateService.getCandidateById).toHaveBeenCalledWith(candidateId);
        expect(res.status).toHaveBeenCalledWith(404);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Candidate not found',
        });
    });

    it('should return 500 for database connection errors', async () => {
        const candidateId = 1;
        (candidateService.getCandidateById as jest.Mock).mockRejectedValue(new Error('Database connection error'));

        const req = mockRequest({ id: candidateId });
        const res = mockResponse();

        await getCandidateByIdController(req as Request, res as Response);

        expect(candidateService.getCandidateById).toHaveBeenCalledWith(candidateId);
        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Internal server error',
        });
    });
});