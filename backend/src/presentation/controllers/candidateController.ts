import { Request, Response } from 'express';
import { addCandidate, getCandidateById } from '../../application/services/candidateService';

export const addCandidateController = async (req: Request, res: Response) => {
    try {
        const candidateData = req.body;
        const candidate = await addCandidate(candidateData);
        res.status(201).json({ message: 'Candidate added successfully', data: candidate });
    } catch (error: unknown) {
        if (error instanceof Error) {
            res.status(400).json({ message: 'Error adding candidate', error: error.message });
        } else {
            res.status(400).json({ message: 'Error adding candidate', error: 'Unknown error' });
        }
    }
};

export const getCandidateByIdController = async (req: Request, res: Response) => {
    const { id } = req.params;
    if (isNaN(Number(id))) {
        return res.status(400).json({ message: 'Invalid candidate ID' });
    }

    try {
        const candidate = await getCandidateById(Number(id));
        if (!candidate) {
            return res.status(404).json({ message: 'Candidate not found' });
        }
        res.status(200).json(candidate);
    } catch (error: unknown) {
        res.status(500).json({ message: 'Internal server error' });
    }
};

export { addCandidate, getCandidateById };