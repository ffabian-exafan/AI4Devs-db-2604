import { Education } from './Education';
import { PrismaClient, Prisma } from '@prisma/client';

jest.mock('@prisma/client', () => {
    const mPrismaClient = {
        education: {
            create: jest.fn(),
            update: jest.fn(),
        },
    };
    return { PrismaClient: jest.fn(() => mPrismaClient) };
});

const prisma = new PrismaClient();

describe('Education Model', () => {
    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('Constructor', () => {
        it('should initialize properties correctly', () => {
            const data = {
                id: 1,
                institution: 'University',
                title: 'BSc',
                startDate: '2020-01-01',
                endDate: '2023-01-01',
                candidateId: 1,
            };
            const education = new Education(data);
            expect(education).toMatchObject({
                id: data.id,
                institution: data.institution,
                title: data.title,
                startDate: new Date(data.startDate),
                endDate: new Date(data.endDate),
                candidateId: data.candidateId,
            });
        });
    });

    describe('save', () => {
        it('should create a new education record if id is not defined', async () => {
            const data = {
                institution: 'University',
                title: 'BSc',
                startDate: '2020-01-01',
                endDate: '2023-01-01',
                candidateId: 1,
            };
            const education = new Education(data);
            const savedEducation = { id: 1, ...data };
            (prisma.education.create as jest.Mock).mockResolvedValue(savedEducation);

            const result = await education.save();
            expect(prisma.education.create).toHaveBeenCalledWith({
                data: {
                    institution: data.institution,
                    title: data.title,
                    startDate: new Date(data.startDate),
                    endDate: new Date(data.endDate),
                    candidateId: data.candidateId,
                },
            });
            expect(result).toEqual(savedEducation);
        });

        it('should update an existing education record if id is defined', async () => {
            const data = {
                id: 1,
                institution: 'University',
                title: 'BSc',
                startDate: '2020-01-01',
                endDate: '2023-01-01',
                candidateId: 1,
            };
            const education = new Education(data);
            const updatedEducation = { ...data };
            (prisma.education.update as jest.Mock).mockResolvedValue(updatedEducation);

            const result = await education.save();
            expect(prisma.education.update).toHaveBeenCalledWith({
                where: { id: data.id },
                data: {
                    institution: data.institution,
                    title: data.title,
                    startDate: new Date(data.startDate),
                    endDate: new Date(data.endDate),
                    candidateId: data.candidateId,
                },
            });
            expect(result).toEqual(updatedEducation);
        });
    });
});