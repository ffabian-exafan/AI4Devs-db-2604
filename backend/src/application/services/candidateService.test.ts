import { addCandidate, getCandidateById } from './candidateService';
import { validateCandidateData } from '../validator';
import { Candidate } from '../../domain/models/Candidate';
import { Education } from '../../domain/models/Education';
import { WorkExperience } from '../../domain/models/WorkExperience';
import { Resume } from '../../domain/models/Resume';

jest.mock('../validator');
jest.mock('../../domain/models/Candidate');
jest.mock('../../domain/models/Education');
jest.mock('../../domain/models/WorkExperience');
jest.mock('../../domain/models/Resume');

const MockedCandidate = jest.mocked(Candidate);
const MockedEducation = jest.mocked(Education);
const MockedWorkExperience = jest.mocked(WorkExperience);
const MockedResume = jest.mocked(Resume);

describe('CandidateService', () => {
    afterEach(() => {
        jest.resetAllMocks();
    });

    describe('addCandidate', () => {
        it('should validate candidate data', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '1234567890',
                address: '123 Main St',
                educations: [],
                workExperiences: [],
                cv: {}
            };

            // Mock save method to return an object with an id
            const mockSave = jest.fn().mockResolvedValue({ id: 1, ...candidateData });
            MockedCandidate.mockImplementation((data) => ({
                ...data,
                save: mockSave,
                education: [],
                workExperience: [],
                resumes: []
            }));

            await addCandidate(candidateData);
            expect(validateCandidateData).toHaveBeenCalledWith(candidateData);
        });

        it('should create a new candidate', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '1234567890',
                address: '123 Main St',
                educations: [{ degree: 'BSc' }],
                workExperiences: [{ company: 'Company' }],
                cv: { fileName: 'resume.pdf' }
            };

            // Mock save methods for Candidate, Education, WorkExperience, and Resume
            const mockSaveCandidate = jest.fn().mockResolvedValue({ id: 1, ...candidateData });
            const mockSaveEducation = jest.fn().mockResolvedValue({ id: 1, degree: 'BSc', candidateId: 1 });
            const mockSaveWorkExperience = jest.fn().mockResolvedValue({ id: 1, company: 'Company', candidateId: 1 });
            const mockSaveResume = jest.fn().mockResolvedValue({ id: 1, fileName: 'resume.pdf', candidateId: 1 });

            MockedCandidate.mockImplementation((data) => ({
                ...data,
                save: mockSaveCandidate,
                education: [],
                workExperience: [],
                resumes: []
            }));

            MockedEducation.mockImplementation((data) => ({
                ...data,
                save: mockSaveEducation
            }));

            MockedWorkExperience.mockImplementation((data) => ({
                ...data,
                save: mockSaveWorkExperience
            }));

            MockedResume.mockImplementation((data) => ({
                ...data,
                save: mockSaveResume
            }));

            const result = await addCandidate(candidateData);
            expect(mockSaveCandidate).toHaveBeenCalled();
            expect(mockSaveEducation).toHaveBeenCalled();
            expect(mockSaveWorkExperience).toHaveBeenCalled();
            expect(mockSaveResume).toHaveBeenCalled();
            expect(result).toEqual({ id: 1, ...candidateData });
        });

        it('should handle validation errors', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'invalid-email',
                phone: '1234567890',
                address: '123 Main St',
                educations: [],
                workExperiences: [],
                cv: {}
            };

            // Mock validateCandidateData to throw an error
            (validateCandidateData as jest.Mock).mockImplementation(() => {
                throw new Error('Invalid email');
            });

            await expect(addCandidate(candidateData)).rejects.toThrow('Invalid email');
        });

        it('should handle database connection errors', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '1234567890',
                address: '123 Main St',
                educations: [],
                workExperiences: [],
                cv: {}
            };

            // Mock save method to throw a database connection error
            const mockSave = jest.fn().mockRejectedValue(new Error('Database connection error'));
            MockedCandidate.mockImplementation((data) => ({
                ...data,
                save: mockSave,
                education: [],
                workExperience: [],
                resumes: []
            }));

            await expect(addCandidate(candidateData)).rejects.toThrow('Database connection error');
        });

        it('should handle unique constraint errors', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '1234567890',
                address: '123 Main St',
                educations: [],
                workExperiences: [],
                cv: {}
            };

            // Mock save method to throw a unique constraint error
            const mockSave = jest.fn().mockRejectedValue({ code: 'P2002' });
            MockedCandidate.mockImplementation((data) => ({
                ...data,
                save: mockSave,
                education: [],
                workExperience: [],
                resumes: []
            }));

            await expect(addCandidate(candidateData)).rejects.toThrow('The email already exists in the database');
        });
    });

    describe('getCandidateById', () => {
        it('should return candidate information for a valid ID', async () => {
            const candidateId = 1;
            const candidateData = {
                id: candidateId,
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '1234567890',
                address: '123 Main St',
                education: [],
                workExperience: [],
                resumes: []
            };

            MockedCandidate.findOne = jest.fn().mockResolvedValue(candidateData);

            const result = await getCandidateById(candidateId);
            expect(MockedCandidate.findOne).toHaveBeenCalledWith(candidateId);
            expect(result).toEqual(candidateData);
        });

        it('should return null if candidate is not found', async () => {
            const candidateId = 1;

            MockedCandidate.findOne = jest.fn().mockResolvedValue(null);

            const result = await getCandidateById(candidateId);
            expect(MockedCandidate.findOne).toHaveBeenCalledWith(candidateId);
            expect(result).toBeNull();
        });

        it('should handle database connection errors', async () => {
            const candidateId = 1;

            MockedCandidate.findOne = jest.fn().mockRejectedValue(new Error('Database connection error'));

            await expect(getCandidateById(candidateId)).rejects.toThrow('Database connection error');
        });
    });
});